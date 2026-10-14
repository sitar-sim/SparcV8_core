from setuptools import setup, find_packages

setup(
    name="mcode-mkdocs-lexer",
    version="0.1.0",
    description="Pygments lexer for the APARA engine's assembly language (mcode)",
    packages=find_packages(),
    entry_points={
        "pygments.lexers": [
            "mcode=mcode_pygments_lexer.mcode:McodeLexer",
        ]
    },
    install_requires=["Pygments>=2.3"],
)
