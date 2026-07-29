#sparc.gdb
#
#Convenience commands for examining a running sparc_sim_cpp/sparc_sim_sitar
#under gdb (built with --debug -- see build.sh/build.py). See
#docs/source/examining_core_state_with_gdb.md for why gdb-based debugging
#exists at all in this repository; this file is purely a convenience
#layer on top of that -- intuitive, memorable names standing in for the
#actual C++ expressions/symbols a user would otherwise have to know by
#heart (e.g. "o1" instead of "core.reg.R_r(9)", "break on any MAE" instead
#of the actual condition syntax). See debug/README.md for the full command
#reference and design rationale.
#
#Load with, from gdb:
#    source debug/sparc.gdb
#or non-interactively:
#    gdb -x debug/sparc.gdb ./sparc_sim_cpp

python

import gdb

#=====================================================================
#Shared helpers
#=====================================================================

def parse_kv(argstr):
	"""'key=value key2 key3=value3' -> {'key':'value', ...}; a bare token
	(no '=') maps to True (used for flags like 'mae'/'persist')."""
	opts = {}
	for tok in (argstr or "").split():
		if '=' in tok:
			k, v = tok.split('=', 1)
			opts[k] = v
		else:
			opts[tok] = True
	return opts


def _mask_size(mask):
	"""Validates mask is trailing-zero form (0xfff...000 -- the zero bits
	define a contiguous, power-of-2-aligned range) and returns the size of
	that range in bytes."""
	mask &= 0xFFFFFFFF
	inv = (~mask) & 0xFFFFFFFF
	if mask != 0 and (inv & (inv + 1)) != 0:
		raise gdb.GdbError("mask must be of the form 0xfff...000 -- trailing "
		                    "zero bits, defining a contiguous power-of-2-aligned range")
	return inv + 1


def addr_condition(expr, spec):
	"""Turns an addr-expr (exact / lo:hi range / base/mask) into a C++
	boolean condition string comparing it against `expr`. See
	debug/README.md for the three forms."""
	spec = spec.strip()
	if '/' in spec:
		base_s, mask_s = spec.split('/', 1)
		base = int(base_s, 0)
		mask = int(mask_s, 0)
		_mask_size(mask)
		return "((%s) & 0x%x) == 0x%x" % (expr, mask, base & mask)
	if ':' in spec:
		lo_s, hi_s = spec.split(':', 1)
		lo = int(lo_s, 0)
		hi = int(hi_s, 0)
		return "((%s) >= 0x%x && (%s) < 0x%x)" % (expr, lo, expr, hi)
	val = int(spec, 0)
	return "((%s) == 0x%x)" % (expr, val)


def addr_range(spec):
	"""Same addr-expr forms, but returns (lo, size_in_bytes) instead of a
	condition -- for sparc-print-mem/sparc-watch-mem, which need an actual
	memory location, not a comparison."""
	spec = spec.strip()
	if '/' in spec:
		base_s, mask_s = spec.split('/', 1)
		base = int(base_s, 0)
		mask = int(mask_s, 0)
		size = _mask_size(mask)
		return (base & mask, size)
	if ':' in spec:
		lo_s, hi_s = spec.split(':', 1)
		lo = int(lo_s, 0)
		hi = int(hi_s, 0)
		return (lo, max(0, hi - lo))
	val = int(spec, 0)
	return (val, 4)


#Register-name syntax: windowed mnemonics (g0-g7/o0-o7/l0-l7/i0-i7), flat
#SPARC r-numbering (r0-r31 -- r1==g1, r9==o1, ...), or the handful of
#special (non-windowed) registers.
REG_SPECIALS = {'pc': 'R_PC', 'npc': 'R_nPC', 'y': 'R_Y',
                'psr': 'R_PSR', 'wim': 'R_WIM', 'tbr': 'R_TBR'}


def reg_suffix(name):
	"""Register name -> the 'reg.XXX' expression suffix (caller prepends
	the core pointer/expression itself)."""
	n = name.strip().lower()
	if n in REG_SPECIALS:
		return "reg.%s()" % REG_SPECIALS[n]
	if len(n) >= 2 and n[0] in 'golir' and n[1:].isdigit():
		idx = int(n[1:])
		if n[0] == 'r':
			if not (0 <= idx <= 31):
				raise gdb.GdbError("r-number must be 0-31: %s" % name)
			return "reg.R_r(%d)" % idx
		if not (0 <= idx <= 7):
			raise gdb.GdbError("register number must be 0-7: %s" % name)
		base = {'g': 0, 'o': 8, 'l': 16, 'i': 24}[n[0]]
		return "reg.R_r(%d)" % (base + idx)
	raise gdb.GdbError("unrecognized register name: %s (try g0-g7/o0-o7/l0-l7/i0-i7, "
	                    "r0-r31, or pc/npc/y/psr/wim/tbr)" % name)


#DebugRegistry::findCoreByID()/firstMemCore() (cpp_common_code/DebugRegistry.h)
#are what make all of this reachable from *any* stopped frame, in either
#model -- see that file's own comment.

def _require_running():
	if gdb.selected_inferior().pid == 0:
		raise gdb.GdbError("this needs a running process (registries are runtime "
		                    "state) -- `run` first")


def core_ptr(coreid):
	_require_running()
	v = int(gdb.parse_and_eval("(unsigned long)DebugRegistry::findCoreByID(%uu)" % coreid))
	if v == 0:
		raise gdb.GdbError("no core with coreid=%d registered -- built with --debug, "
		                    "and past SparcCore's constructor?" % coreid)
	return v


def core_field(coreid, suffix):
	"""Evaluates '<suffix>' against the SparcCore with the given coreid,
	e.g. core_field(0, "reg.PC") or core_field(0, "printTrap()")."""
	return gdb.parse_and_eval("((SparcCore*)%d)->%s" % (core_ptr(coreid), suffix))


def core_string(coreid, suffix):
	"""Like core_field(), but for an expression whose type is std::string
	(e.g. suffix="printTrap()" or "logger.print_state()"): returns a clean
	Python str, read out immediately via .c_str()/.string() rather than
	gdb's std::string pretty-printer, which both quotes+backslash-escapes
	embedded newlines and truncates past 'print elements' (200 by
	default) -- wrong on both counts for a multi-line dump like
	print_state(). Reading it out this way, in one combined expression,
	also sidesteps a separate hazard: the returned std::string is a
	temporary living in the inferior's own (reused/reusable) memory, so a
	*later*, unrelated inferior call could otherwise clobber it before a
	lazily-held gdb.Value ever got read (see the version-controlled
	history of this file for the bug this actually was)."""
	return gdb.parse_and_eval("((SparcCore*)%d)->%s.c_str()" % (core_ptr(coreid), suffix)).string()


def mem_ptr():
	_require_running()
	v = int(gdb.parse_and_eval("(unsigned long)DebugRegistry::firstMemCore()"))
	if v == 0:
		raise gdb.GdbError("no MemCore registered -- built with --debug?")
	return v


def byte_ptr(addr):
	"""Raw host address of simulated byte address `addr`, via
	MemCore::wordPtr() (word-granularity storage, so this reads the
	containing word's pointer and adds the in-word byte offset)."""
	word_host_addr = int(gdb.parse_and_eval(
		"(unsigned long)((MemCore*)%d)->wordPtr(0x%x)" % (mem_ptr(), addr & ~0x3)))
	return word_host_addr + (addr & 0x3)


#=====================================================================
#Registry, for sparc-list/sparc-delete: gdb's own `info breakpoints`
#shows every sparc-* breakpoint too, but only its raw translated
#condition -- this keeps the friendly label each was created with.
#=====================================================================

_registry = []
_next_id = [1]


def register_bp(label, bp, kind):
	entry = {'id': _next_id[0], 'label': label, 'bp': bp, 'kind': kind}
	_registry.append(entry)
	_next_id[0] += 1
	print("[sparc #%d] %s (gdb breakpoint #%d)" % (entry['id'], label, bp.number))
	return entry['id']


class SparcList(gdb.Command):
	"""sparc-list
List every sparc-break-*/sparc-watch-* currently set, with the friendly
label each was created with."""
	def __init__(self):
		super(SparcList, self).__init__("sparc-list", gdb.COMMAND_BREAKPOINTS)

	def invoke(self, arg, from_tty):
		_registry[:] = [e for e in _registry if e['bp'].is_valid()]
		if not _registry:
			print("No sparc-* breakpoints/watchpoints set.")
			return
		print("%-4s %-6s %-6s %-6s %s" % ("id", "gdb#", "kind", "hits", "description"))
		for e in _registry:
			print("%-4d %-6d %-6s %-6d %s" % (e['id'], e['bp'].number, e['kind'],
			                                   e['bp'].hit_count, e['label']))


class SparcDelete(gdb.Command):
	"""sparc-delete <id>
Delete a sparc-* breakpoint/watchpoint by its sparc-list id (gdb's own
`delete <N>`, using the gdb# sparc-list shows, works too)."""
	def __init__(self):
		super(SparcDelete, self).__init__("sparc-delete", gdb.COMMAND_BREAKPOINTS)

	def invoke(self, arg, from_tty):
		arg = arg.strip()
		if not arg:
			raise gdb.GdbError("usage: sparc-delete <id>  (see sparc-list)")
		wanted = int(arg, 0)
		for e in list(_registry):
			if e['id'] == wanted:
				if e['bp'].is_valid():
					e['bp'].delete()
				_registry.remove(e)
				print("Deleted sparc #%d (%s)" % (wanted, e['label']))
				return
		raise gdb.GdbError("no sparc-* entry with id %d (see sparc-list)" % wanted)


#=====================================================================
#Breakpoints
#=====================================================================

class SparcBreak(gdb.Command):
	"""sparc-break pc=<addr-expr> [coreid=<n>]
Break at debug_hook_after_execute (instruction fully executed, PC/nPC not
yet advanced) when PC matches <addr-expr> (exact / lo:hi / base/mask --
see debug/README.md)."""
	def __init__(self):
		super(SparcBreak, self).__init__("sparc-break", gdb.COMMAND_BREAKPOINTS)

	def invoke(self, arg, from_tty):
		opts = parse_kv(arg)
		if 'pc' not in opts:
			raise gdb.GdbError("usage: sparc-break pc=<addr-expr> [coreid=<n>]")
		cond = addr_condition("core.reg.PC", opts['pc'])
		if 'coreid' in opts:
			cond += " && core.coreID == %d" % int(opts['coreid'], 0)
		bp = gdb.Breakpoint("debug_hook_after_execute")
		bp.condition = cond
		register_bp("break pc=%s" % opts['pc'], bp, "break")


class SparcBreakNth(gdb.Command):
	"""sparc-break-nth pc=<addr-expr> n=<k> [coreid=<n>]
Like sparc-break, but only actually stops on the k-th match (gdb's own
ignore-count)."""
	def __init__(self):
		super(SparcBreakNth, self).__init__("sparc-break-nth", gdb.COMMAND_BREAKPOINTS)

	def invoke(self, arg, from_tty):
		opts = parse_kv(arg)
		if 'pc' not in opts or 'n' not in opts:
			raise gdb.GdbError("usage: sparc-break-nth pc=<addr-expr> n=<k> [coreid=<n>]")
		n = int(opts['n'], 0)
		cond = addr_condition("core.reg.PC", opts['pc'])
		if 'coreid' in opts:
			cond += " && core.coreID == %d" % int(opts['coreid'], 0)
		bp = gdb.Breakpoint("debug_hook_after_execute")
		bp.condition = cond
		if n > 1:
			bp.ignore_count = n - 1
		register_bp("break-nth pc=%s n=%d" % (opts['pc'], n), bp, "break")


#Same cause names SparcCore::printTrap() itself reports (see SparcCore.cpp's
#selectTrap()/printTrap()) -- these are the boolean flags still valid to
#read at debug_hook_trap_raised (before selectTrap() clears them).
TRAP_CAUSE_NAMES = [
	"reset_trap", "data_store_error", "instruction_access_error",
	"r_register_access_error", "instruction_access_exception",
	"privileged_instruction", "illegal_instruction", "fp_disabled",
	"cp_disabled", "unimplemented_FLUSH", "window_overflow",
	"window_underflow", "mem_address_not_aligned", "fp_exception",
	"cp_exception", "data_access_error", "data_access_exception",
	"tag_overflow", "division_by_zero", "trap_instruction",
]


class SparcBreakTrap(gdb.Command):
	"""sparc-break-trap [type=<name>] [coreid=<n>]
Break at debug_hook_trap_raised. <name> is one of the same cause names
core.printTrap() itself reports (illegal_instruction, window_overflow,
trap_instruction, external_interrupt, ...); omit for any cause."""
	def __init__(self):
		super(SparcBreakTrap, self).__init__("sparc-break-trap", gdb.COMMAND_BREAKPOINTS)

	def invoke(self, arg, from_tty):
		opts = parse_kv(arg)
		conds = []
		if 'type' in opts:
			t = opts['type']
			if t == 'external_interrupt':
				conds.append("core.interrupt_level > 0")
			elif t in TRAP_CAUSE_NAMES:
				conds.append("core.%s == 1" % t)
			else:
				raise gdb.GdbError("unrecognized trap type: %s (see debug/README.md for the list)" % t)
		if 'coreid' in opts:
			conds.append("core.coreID == %d" % int(opts['coreid'], 0))
		bp = gdb.Breakpoint("debug_hook_trap_raised")
		if conds:
			bp.condition = " && ".join(conds)
		register_bp("break-trap%s" % ((" type=" + opts['type']) if 'type' in opts else " (any)"), bp, "break")


class SparcBreakMae(gdb.Command):
	"""sparc-break-mae [coreid=<n>]
Break at debug_hook_mem_access whenever core.MAE is set -- any kind, any
address. The simple, no-thought shortcut for a rare event; for anything
more specific (a particular kind/address), use sparc-break-mem with
mae added."""
	def __init__(self):
		super(SparcBreakMae, self).__init__("sparc-break-mae", gdb.COMMAND_BREAKPOINTS)

	def invoke(self, arg, from_tty):
		opts = parse_kv(arg)
		cond = "core.MAE"
		if 'coreid' in opts:
			cond += " && core.coreID == %d" % int(opts['coreid'], 0)
		bp = gdb.Breakpoint("debug_hook_mem_access")
		bp.condition = cond
		register_bp("break-mae", bp, "break")


MEM_KINDS = {"ifetch": "IFETCH", "load": "LOAD", "store": "STORE",
             "atomic": "ATOMIC", "flush": "FLUSH"}


class SparcBreakMem(gdb.Command):
	"""sparc-break-mem [kind=<ifetch|load|store|atomic|flush>] [addr=<addr-expr>] [data=<hex>] [mae] [coreid=<n>]
Break at debug_hook_mem_access, filtered by any combination of kind,
address, data (word0 -- meaningful for load/store/atomic), and/or a
faulting access (mae). All arguments optional and combinable, e.g.:
  sparc-break-mem kind=load addr=0x2000:0x2100
  sparc-break-mem kind=load mae
  sparc-break-mem kind=ifetch addr=0x2054"""
	def __init__(self):
		super(SparcBreakMem, self).__init__("sparc-break-mem", gdb.COMMAND_BREAKPOINTS)

	def invoke(self, arg, from_tty):
		opts = parse_kv(arg)
		conds = []
		if 'kind' in opts:
			k = opts['kind'].lower()
			if k not in MEM_KINDS:
				raise gdb.GdbError("unrecognized kind: %s (ifetch/load/store/atomic/flush)" % opts['kind'])
			conds.append("kind == DebugMemAccessKind::%s" % MEM_KINDS[k])
		if 'addr' in opts:
			conds.append(addr_condition("address", opts['addr']))
		if 'data' in opts:
			conds.append("word0 == 0x%x" % int(opts['data'], 0))
		if 'mae' in opts:
			conds.append("core.MAE")
		if 'coreid' in opts:
			conds.append("core.coreID == %d" % int(opts['coreid'], 0))
		bp = gdb.Breakpoint("debug_hook_mem_access")
		if conds:
			bp.condition = " && ".join(conds)
		register_bp("break-mem %s" % (arg or "(any)"), bp, "break")


class SparcBreakAnnulled(gdb.Command):
	"""sparc-break-annulled [pc=<addr-expr>] [coreid=<n>]
Break at debug_hook_annulled -- fires before PC/nPC are updated for the
skip, so core.reg.PC/nPC are the annulled instruction's own address and
what it advances to. pc is optional -- omit to catch every annul, which
can be very frequent; usually worth narrowing to a specific pc."""
	def __init__(self):
		super(SparcBreakAnnulled, self).__init__("sparc-break-annulled", gdb.COMMAND_BREAKPOINTS)

	def invoke(self, arg, from_tty):
		opts = parse_kv(arg)
		conds = []
		if 'pc' in opts:
			conds.append(addr_condition("core.reg.PC", opts['pc']))
		if 'coreid' in opts:
			conds.append("core.coreID == %d" % int(opts['coreid'], 0))
		bp = gdb.Breakpoint("debug_hook_annulled")
		if conds:
			bp.condition = " && ".join(conds)
		register_bp("break-annulled %s" % (arg or "(any)"), bp, "break")


#=====================================================================
#Watchpoints
#=====================================================================

class SparcWatchMem(gdb.Command):
	"""sparc-watch-mem addr=<addr-expr> [coreid=<n>]
True hardware watchpoint on simulated memory -- fires the instant the
value changes, wherever/whenever that happens (mid-instruction included).
addr is exact, lo:hi range, or base/mask (mask must be trailing-zero form,
defining a contiguous power-of-2-aligned region -- large ranges may
silently fall back to a slow software watchpoint if the host has no
hardware debug register wide enough). Contrast with sparc-watch-reg, which
checks only at instruction boundaries."""
	def __init__(self):
		super(SparcWatchMem, self).__init__("sparc-watch-mem", gdb.COMMAND_BREAKPOINTS)

	def invoke(self, arg, from_tty):
		opts = parse_kv(arg)
		if 'addr' not in opts:
			raise gdb.GdbError("usage: sparc-watch-mem addr=<addr-expr> [coreid=<n>]")
		lo, size = addr_range(opts['addr'])
		base = byte_ptr(lo)
		if size <= 4:
			spec = "*(unsigned int*)%d" % base
		else:
			spec = "*(char(*)[%d])%d" % (size, base)
		bp = gdb.Breakpoint(spec, gdb.BP_WATCHPOINT, gdb.WP_WRITE)
		register_bp("watch-mem addr=%s" % opts['addr'], bp, "watch")


class _SparcWatchRegBP(gdb.Breakpoint):
	"""Not a hardware watchpoint -- see SparcWatchReg's docstring for why.
	A conditional breakpoint on debug_hook_after_execute that maintains
	its own state (last value seen / whether it was already matching)
	across hits, so it only actually stops on a genuine edge (or every
	hit, if persist)."""
	def __init__(self, reg, coreid, value, mask, persist):
		super(_SparcWatchRegBP, self).__init__("debug_hook_after_execute", internal=False)
		self.suffix = reg_suffix(reg)
		self.coreid = coreid
		self.value = value
		self.mask = mask if mask is not None else 0xFFFFFFFF
		self.persist = persist
		self.have_last = False
		self.last = 0
		self.was_matching = False

	def stop(self):
		try:
			cur = int(core_field(self.coreid, self.suffix)) & 0xFFFFFFFF
		except gdb.error:
			return False
		if self.value is None:
			fire = self.have_last and (cur != self.last)
			self.last = cur
			self.have_last = True
			return fire
		matches = (cur & self.mask) == (self.value & self.mask)
		fire = matches if self.persist else (matches and not self.was_matching)
		self.was_matching = matches
		self.last = cur
		self.have_last = True
		return fire


class SparcWatchReg(gdb.Command):
	"""sparc-watch-reg <reg> [value=<hex>] [mask=<hex>] [persist] [coreid=<n>]
Not a hardware watchpoint: a real one fires the instant the underlying
storage changes, which for a register can be mid-instruction (e.g. window
shuffling), before the value is architecturally committed. This instead
checks <reg> once per instruction, at debug_hook_after_execute -- the
stable, retired value -- comparing it against its value at the previous
check. Edge-triggered by default: fires once, on the transition into a
new value (no value= given) or into a matching one (value=/mask= given).
Add [persist] to instead fire on every instruction the value/mask
condition holds (only meaningful together with value=)."""
	def __init__(self):
		super(SparcWatchReg, self).__init__("sparc-watch-reg", gdb.COMMAND_BREAKPOINTS)

	def invoke(self, arg, from_tty):
		parts = arg.split()
		if not parts:
			raise gdb.GdbError("usage: sparc-watch-reg <reg> [value=<hex>] [mask=<hex>] [persist] [coreid=<n>]")
		reg = parts[0]
		reg_suffix(reg)  #validate early, before creating the breakpoint
		opts = parse_kv(" ".join(parts[1:]))
		value = int(opts['value'], 0) if 'value' in opts else None
		mask = int(opts['mask'], 0) if 'mask' in opts else None
		persist = bool(opts.get('persist', False))
		coreid = int(opts['coreid'], 0) if 'coreid' in opts else 0
		if persist and value is None:
			raise gdb.GdbError("[persist] only makes sense together with value= "
			                    "(there's no target to hold for plain change-detection)")
		label = "watch-reg %s%s%s" % (
			reg,
			(" value=0x%x" % value) if value is not None else "",
			" persist" if persist else "")
		bp = _SparcWatchRegBP(reg, coreid, value, mask, persist)
		register_bp(label, bp, "watch")


#=====================================================================
#Probe / print
#=====================================================================

class SparcPrintRegs(gdb.Command):
	"""sparc-print-regs [coreid=<n>]
Full register/PSR dump (CoreLogger::print_state()). Works from any frame,
not just inside a hook."""
	def __init__(self):
		super(SparcPrintRegs, self).__init__("sparc-print-regs", gdb.COMMAND_DATA)

	def invoke(self, arg, from_tty):
		opts = parse_kv(arg)
		coreid = int(opts['coreid'], 0) if 'coreid' in opts else 0
		print(core_string(coreid, "logger.print_state()"))


class SparcPrintReg(gdb.Command):
	"""sparc-print-reg <reg> [coreid=<n>]
One register's value -- windowed mnemonic (o1/l2/i4/...), flat r-number
(r0-r31), or special (pc/npc/y/psr/wim/tbr)."""
	def __init__(self):
		super(SparcPrintReg, self).__init__("sparc-print-reg", gdb.COMMAND_DATA)

	def invoke(self, arg, from_tty):
		parts = arg.split()
		if not parts:
			raise gdb.GdbError("usage: sparc-print-reg <reg> [coreid=<n>]")
		reg = parts[0]
		suffix = reg_suffix(reg)
		opts = parse_kv(" ".join(parts[1:]))
		coreid = int(opts['coreid'], 0) if 'coreid' in opts else 0
		val = int(core_field(coreid, suffix)) & 0xFFFFFFFF
		print("%s = 0x%x (%d)" % (reg, val, val))


class SparcPrintTraps(gdb.Command):
	"""sparc-print-traps [coreid=<n>]
Trap cause (core.printTrap()), TBR, PC, and the ET/PS/S PSR bits."""
	def __init__(self):
		super(SparcPrintTraps, self).__init__("sparc-print-traps", gdb.COMMAND_DATA)

	def invoke(self, arg, from_tty):
		opts = parse_kv(arg)
		coreid = int(opts['coreid'], 0) if 'coreid' in opts else 0
		cause = core_string(coreid, "printTrap()")
		tbr = int(core_field(coreid, "reg.TBR")) & 0xFFFFFFFF
		pc = int(core_field(coreid, "reg.PC")) & 0xFFFFFFFF
		et = int(core_field(coreid, "reg.R_ET()"))
		ps = int(core_field(coreid, "reg.R_PS()"))
		s = int(core_field(coreid, "reg.R_S()"))
		print("cause  = %s" % cause)
		print("TBR    = 0x%x" % tbr)
		print("PC     = 0x%x" % pc)
		print("PSR.ET = %d   PSR.PS = %d   PSR.S = %d" % (et, ps, s))


class SparcPrintAnnulled(gdb.Command):
	"""sparc-print-annulled
pc/npc/raw instruction word of the annul currently stopped at
(debug_hook_annulled) -- cross-check the pc against an objdump to see what
instruction it was; not decoded here (annulled instructions are
deliberately never decoded by the model itself)."""
	def __init__(self):
		super(SparcPrintAnnulled, self).__init__("sparc-print-annulled", gdb.COMMAND_DATA)

	def invoke(self, arg, from_tty):
		frame = gdb.selected_frame()
		if frame.name() != "debug_hook_annulled":
			raise gdb.GdbError("not stopped in debug_hook_annulled -- use sparc-break-annulled first")
		core = frame.read_var("core")
		pc = int(core['reg']['PC']) & 0xFFFFFFFF
		npc = int(core['reg']['nPC']) & 0xFFFFFFFF
		instr = int(core['reg']['instruction']) & 0xFFFFFFFF
		print("pc = 0x%x   npc = 0x%x   instruction word = 0x%08x" % (pc, npc, instr))


class SparcPrintMemAccess(gdb.Command):
	"""sparc-print-mem-access
While stopped in debug_hook_mem_access, prints that access's own
kind/address/word0/word1/MAE directly -- whatever memory reference just
completed, even if no register was updated. No coreid= here: this reads
the current frame's own core, there is nothing to select."""
	def __init__(self):
		super(SparcPrintMemAccess, self).__init__("sparc-print-mem-access", gdb.COMMAND_DATA)

	def invoke(self, arg, from_tty):
		frame = gdb.selected_frame()
		if frame.name() != "debug_hook_mem_access":
			raise gdb.GdbError("not stopped in debug_hook_mem_access -- use sparc-break-mem first")
		#str(kind) on this gdb.Value prints the enum's scoped name (e.g.
		#"DebugMemAccessKind::STORE"); strip that down to just STORE,
		#matching the plain kind= filter values sparc-break-mem takes.
		kind = str(frame.read_var("kind")).split("::")[-1]
		address = int(frame.read_var("address")) & 0xFFFFFFFF
		word0 = int(frame.read_var("word0")) & 0xFFFFFFFF
		word1 = int(frame.read_var("word1")) & 0xFFFFFFFF
		mae = int(frame.read_var("core")['MAE'])
		print("kind=%s address=0x%x word0=0x%x word1=0x%x MAE=%d" % (kind, address, word0, word1, mae))


class SparcPrintMem(gdb.Command):
	"""sparc-print-mem addr=<addr-expr>
Reads and prints live memory content at addr (exact/lo:hi/base-mask, see
"Address/PC syntax" -- the number of words printed is however many the
range covers, one word for an exact address), from anywhere, in hex. No
coreid= here: memory isn't owned per-core in this model (exactly one
MemCore exists regardless of core count)."""
	def __init__(self):
		super(SparcPrintMem, self).__init__("sparc-print-mem", gdb.COMMAND_DATA)

	def invoke(self, arg, from_tty):
		opts = parse_kv(arg)
		if 'addr' not in opts:
			raise gdb.GdbError("usage: sparc-print-mem addr=<addr-expr>")
		lo, size = addr_range(opts['addr'])
		n = max(1, (size + 3) // 4)
		vals = []
		for i in range(n):
			a = (lo & ~0x3) + i * 4
			wp = int(gdb.parse_and_eval("(unsigned long)((MemCore*)%d)->wordPtr(0x%x)" % (mem_ptr(), a)))
			vals.append(int(gdb.parse_and_eval("*(unsigned int*)%d" % wp)) & 0xFFFFFFFF)
		print(" ".join("0x%08x" % v for v in vals))


#=====================================================================
#Register everything
#=====================================================================

SparcList()
SparcDelete()
SparcBreak()
SparcBreakNth()
SparcBreakTrap()
SparcBreakMae()
SparcBreakMem()
SparcBreakAnnulled()
SparcWatchMem()
SparcWatchReg()
SparcPrintRegs()
SparcPrintReg()
SparcPrintTraps()
SparcPrintAnnulled()
SparcPrintMemAccess()
SparcPrintMem()

print("sparc.gdb loaded. sparc-list / sparc-delete <id> to manage breakpoints "
      "and watchpoints set with the commands below; see debug/README.md for "
      "the full reference.")

end
