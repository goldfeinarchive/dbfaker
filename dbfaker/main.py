from dbfaker._version import __version__

import click
from dotenv import load_dotenv
from faker import Faker


class Table:
    def __init__(self, name: str, fields: list, data: list):
        self.name = name
        self.fields = fields
        self.data = data

    def output(self):
        with open(f'{self.name}.sql', 'w') as f:
            f.write(f"COPY public.{self.name}({','.join(self.fields)}) FROM stdin;\n")
            for row in self.data:
                 # Convert the data to a tab-delimited string
                tab_delimited_string = '\t'.join(map(str, row)) + '\n'
                f.write(tab_delimited_string)


@click.command()
@click.version_option(__version__)
def main():
    fake = Faker()
    numrecs = 1000
    id = range(1, numrecs + 1)
    name = set(fake.unique.company() for i in range(numrecs))
    created_at = list(fake.date_time_between(start_date='-1y', end_date='now', tzinfo=None).strftime('%Y-%m-%d %H:%M:%S') for i in range(numrecs))
    updated_at = created_at
    data = list(zip(id, name, created_at, updated_at, [0] * numrecs))
    fake.company()

    insurers = Table('insurers',
                     ['id', 'name', 'created_at', 'updated_at', 'insurance_history_records_count'],
                     data
                     )

    insurers.output()

if __name__ == "__main__":
    main()
