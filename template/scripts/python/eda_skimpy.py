#!/usr/bin/env python3

# NOTE https://aeturrell.github.io/skimpy/

from skimpy import clean_columns

columns = [
    "bs lncs;n edbn ",
    "Nín hǎo. Wǒ shì zhōng guó rén",
    "___This is a test___",
    "ÜBER Über German Umlaut",
]
messy_df = pd.DataFrame(columns=columns, index=[0], data=[range(len(columns))])
print("Column names:")
print(list(messy_df.columns))
