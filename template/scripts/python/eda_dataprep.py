#!/usr/bin/env python3

# NOTE https://docs.dataprep.ai/index.html


import numpy as np
import pandas as pd

pd.set_option("display.max_colwidth", None)

df = pd.DataFrame(
    {
        "text": [
            "'ZZZZZ!' If IMDb would allow one-word reviews, that's what mine would be.",
            "The cast played Shakespeare.<br /><br />Shakespeare lost.",
            "Simon of the Desert (Simón del desierto) is a 1965 film directed by Luis Buñuel.",
            "[SPOILERS]\nI don't think I've seen a film this bad before {acting, script, effects (!), etc...}",
            "<a href='/festivals/cannes-1968-a-video-essay'>Cannes 1968:\tA video essay</a>",
            "Recap thread for @RottenTomatoes excellent panel, hosted by @ErikDavis with @FilmFatale_NYC and @AshCrossan.",
            "#GameOfThrones: Season 8 is #Rotten at 54% on the #Tomatometer.  But does it deserve to be?",
            "Come join and share your thoughts on this week's episode: https://twitter.com/i/spaces/1fake2URL3",
            123,
            np.nan,
            "NULL",
        ]
    }
)

from dataprep.clean import clean_text

clean_text(df, "text")
