from wolframclient.evaluation import WolframLanguageSession
from wolframclient.language import wl, wlexpr
import pandas



session = WolframLanguageSession()

session.evaluate(wlexpr('Range[5]'))

session.evaluate(wl.MinMax([1, -3, 0, 9, 5]))

df = pandas.DataFrame({'A': [1, 2], 'B': [11, 12]}, index=['id1', 'id2'])

session.evaluate(wl.Total(df))

wl.Quantity(12, "Hours")

wlexpr('f[x_] := x^2')

limit = wlexpr('Limit[x Log[x^2], x -> 0]')
session.evaluate(limit)

ocean = wlexpr('GeoNearest[Entity["Ocean"], Here]')
session.evaluate(ocean)

session.evaluate(wl.WolframAlpha("number of moons of Saturn", "Result"))


session.terminate()
