from setuptools import setup, find_packages

setup(
    name="sparc-mkdocs-lexer",
    version="0.1.0",
    description="Pygments lexer for SPARC V8 assembly",
    packages=find_packages(),
    entry_points={
        "pygments.lexers": [
            "sparc=sparc_pygments_lexer.sparc:SparcLexer",
        ]
    },
    install_requires=["Pygments>=2.3"],
)
