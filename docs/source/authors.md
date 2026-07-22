# Authors

This project is developed and maintained by:

**Neha Karanjkar**
[https://nehakaranjkar.github.io/](https://nehakaranjkar.github.io/)
IIT Goa

**Madhav Desai**
[https://www.ee.iitb.ac.in/web/people/madhav-p-desai/](https://www.ee.iitb.ac.in/web/people/madhav-p-desai/)
IIT Bombay

This project is built on [Sitar](https://sitar-sim.github.io/sitar/),
also authored by Neha Karanjkar and Madhav Desai. See
[Sitar's own authors page](https://sitar-sim.github.io/sitar/authors.html)
for that project's contributors.

---

## Credits

The functional validation suite under `validation/asm/` is adapted from
the **AJIT processor project** (IIT Bombay), specifically its `ajit32`
instruction-level verification suite:

- Repository: [github.com/adhuliya/ajit-toolchain](https://github.com/adhuliya/ajit-toolchain)
- Test suite source: [.../tests/verification/ajit32](https://github.com/adhuliya/ajit-toolchain/tree/master/tests/verification/ajit32)

Individual test files carry their original author credit inline. Authors
of the adapted tests, in addition to Neha Karanjkar and Madhav Desai
above:

- Piyush P. Soni
- Titto Thomas
- Aniket Deshmukh
- Ashfaque Ahammed

See `validation/README.md` for which tests were adapted as-is versus
written new for this project (the quad-precision suite), and
`docs/compliance/README.md` for a handful of specific, documented divergences
between this model's behavior and AJIT's own reference results.
