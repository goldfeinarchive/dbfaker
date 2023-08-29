from ._version import __version__

import click
from dotenv import load_dotenv

@click.command()
@click.version_option(__version__)
def main():
    print("Hello World!")


if __name__ == "__main__":
    main()
