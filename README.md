A repository with information on New York City Council Legislation, Legislators and Council Events. This mirrors the [NYC Council Legislation](https://legistar.council.nyc.gov/Legislation.aspx) website via the [Legislative API](https://council.nyc.gov/legislation/api/).

Data is generated with [`legislator`](https://github.com/jehiah/legislator) a Go client for the [Legistar API](http://webapi.legistar.com/Help) run by [Granicus](https://granicus.com/legislative-management/)

This data powers https://intro.nyc/

### Data Structure

* **Intro** `introduction/$year/$number.json` i.e. `introduction/2022/0501.json`
* **Event** `events/$year/$date-$body-$id.json` i.e. `events/2023/2023-01-13_12_00_transportation-and-infrastructure_19766.json`
* **People** `people/$slug.json` i.e. `people/lincoln-restler.json`

### How can I use this data?

One way to do analysis on flat files is using tools like [`jq`](https://stedolan.github.io/jq/) and command line visualization tools like [`data_hacks`](https://github.com/bitly/data_hacks)

To quantify the number of sponsors on passed legislation you would filter to passed legislation with `select(.StatusName == "Enacted")` and count the number of sponsors with `.Sponsors | length` and then calculate a histogram.

Passed legislation most frequently had 7 sponsors (44 times == 7.41% of the time)

```
cat introduction/20{18,19,20,21}/*.json | jq -c 'select(.StatusName == "Enacted") | .Sponsors | length' | \
histogram.py --min=0 --max=51 --buckets=51 --percent

# NumSamples = 594; Min = 0.00; Max = 51.00
# Mean = 11.747475; Variance = 78.407611; SD = 8.854807; Median 10.000000
# each ∎ represents a count of 1
    0.0000 -     1.0000 [    29]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (4.88%)
    1.0000 -     2.0000 [    24]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (4.04%)
    2.0000 -     3.0000 [    22]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (3.70%)
    3.0000 -     4.0000 [    17]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.86%)
    4.0000 -     5.0000 [    37]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (6.23%)
    5.0000 -     6.0000 [    41]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (6.90%)
    6.0000 -     7.0000 [    44]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (7.41%)
    7.0000 -     8.0000 [    42]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (7.07%)
    8.0000 -     9.0000 [    35]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (5.89%)
    9.0000 -    10.0000 [    38]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (6.40%)
   10.0000 -    11.0000 [    33]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (5.56%)
   11.0000 -    12.0000 [    38]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (6.40%)
   12.0000 -    13.0000 [    27]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (4.55%)
   13.0000 -    14.0000 [    19]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (3.20%)
   14.0000 -    15.0000 [    14]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.36%)
   15.0000 -    16.0000 [    16]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.69%)
   16.0000 -    17.0000 [    14]: ∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.36%)
   17.0000 -    18.0000 [     9]: ∎∎∎∎∎∎∎∎∎ (1.52%)
   18.0000 -    19.0000 [    11]: ∎∎∎∎∎∎∎∎∎∎∎ (1.85%)
   19.0000 -    20.0000 [     6]: ∎∎∎∎∎∎ (1.01%)
   20.0000 -    21.0000 [     7]: ∎∎∎∎∎∎∎ (1.18%)
   21.0000 -    22.0000 [     8]: ∎∎∎∎∎∎∎∎ (1.35%)
   22.0000 -    23.0000 [     6]: ∎∎∎∎∎∎ (1.01%)
   23.0000 -    24.0000 [     2]: ∎∎ (0.34%)
   24.0000 -    25.0000 [     1]: ∎ (0.17%)
   25.0000 -    26.0000 [     2]: ∎∎ (0.34%)
   26.0000 -    27.0000 [     2]: ∎∎ (0.34%)
   27.0000 -    28.0000 [     6]: ∎∎∎∎∎∎ (1.01%)
   28.0000 -    29.0000 [     3]: ∎∎∎ (0.51%)
   29.0000 -    30.0000 [     6]: ∎∎∎∎∎∎ (1.01%)
   30.0000 -    31.0000 [     4]: ∎∎∎∎ (0.67%)
   31.0000 -    32.0000 [     3]: ∎∎∎ (0.51%)
   32.0000 -    33.0000 [     3]: ∎∎∎ (0.51%)
   33.0000 -    34.0000 [     3]: ∎∎∎ (0.51%)
   34.0000 -    35.0000 [     4]: ∎∎∎∎ (0.67%)
   35.0000 -    36.0000 [     2]: ∎∎ (0.34%)
   36.0000 -    37.0000 [     2]: ∎∎ (0.34%)
   37.0000 -    38.0000 [     3]: ∎∎∎ (0.51%)
   38.0000 -    39.0000 [     3]: ∎∎∎ (0.51%)
   39.0000 -    40.0000 [     1]: ∎ (0.17%)
   40.0000 -    41.0000 [     0]:  (0.00%)
   41.0000 -    42.0000 [     2]: ∎∎ (0.34%)
   42.0000 -    43.0000 [     0]:  (0.00%)
   43.0000 -    44.0000 [     0]:  (0.00%)
   44.0000 -    45.0000 [     2]: ∎∎ (0.34%)
   45.0000 -    46.0000 [     2]: ∎∎ (0.34%)
   46.0000 -    47.0000 [     1]: ∎ (0.17%)
   47.0000 -    48.0000 [     0]:  (0.00%)
   48.0000 -    49.0000 [     0]:  (0.00%)
   49.0000 -    50.0000 [     0]:  (0.00%)
   50.0000 -    51.0000 [     0]:  (0.00%)
```

To see who sponsored the most passed legislation 

```
$ cat introduction/20{18,19,20,21}/*.json | jq -c 'select(.StatusName == "Enacted") | .Sponsors[] | .FullName ' | \
bar_chart.py --percent --reverse-sort --sort-values

# each ∎ represents a count of 9. total 6934
                      Ben Kallos [   430] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (6.20%)
                 Carlina Rivera  [   376] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (5.42%)
                    Diana Ayala  [   344] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (4.96%)
              Helen K. Rosenthal [   320] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (4.61%)
                Margaret S. Chin [   259] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (3.74%)
                  Brad S. Lander [   255] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (3.68%)
                Stephen T. Levin [   231] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (3.33%)
            Alicka Ampry-Samuel  [   188] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.71%)
         Costa G. Constantinides [   187] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.70%)
                Robert F. Holden [   181] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.61%)
               Justin L. Brannan [   179] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.58%)
                 Deborah L. Rose [   162] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.34%)
                  Inez D. Barron [   162] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.34%)
                  Farah N. Louis [   155] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.24%)
               Adrienne E. Adams [   154] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.22%)
               Vanessa L. Gibson [   144] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.08%)
                   Keith Powers  [   141] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (2.03%)
                 Laurie A. Cumbo [   135] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (1.95%)
                 Paul A. Vallone [   135] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (1.95%)
                I. Daneek Miller [   131] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (1.89%)
                     Mark Levine [   127] ∎∎∎∎∎∎∎∎∎∎∎∎∎∎ (1.83%)
                 Antonio Reynoso [   119] ∎∎∎∎∎∎∎∎∎∎∎∎∎ (1.72%)
                   Kalman Yeger  [   117] ∎∎∎∎∎∎∎∎∎∎∎∎∎ (1.69%)
          Robert E. Cornegy, Jr. [   115] ∎∎∎∎∎∎∎∎∎∎∎∎ (1.66%)
                 Carlos Menchaca [   109] ∎∎∎∎∎∎∎∎∎∎∎∎ (1.57%)
                 Karen Koslowitz [   105] ∎∎∎∎∎∎∎∎∎∎∎ (1.51%)
             Donovan J. Richards [   104] ∎∎∎∎∎∎∎∎∎∎∎ (1.50%)
                   Daniel Dromm  [   100] ∎∎∎∎∎∎∎∎∎∎∎ (1.44%)
                    Andrew Cohen [    98] ∎∎∎∎∎∎∎∎∎∎ (1.41%)
                  Mathieu Eugene [    97] ∎∎∎∎∎∎∎∎∎∎ (1.40%)
             James G. Van Bramer [    96] ∎∎∎∎∎∎∎∎∎∎ (1.38%)
           Rafael Salamanca, Jr. [    93] ∎∎∎∎∎∎∎∎∎∎ (1.34%)
                    Mark Treyger [    92] ∎∎∎∎∎∎∎∎∎∎ (1.33%)
             Ydanis A. Rodriguez [    88] ∎∎∎∎∎∎∎∎∎ (1.27%)
               Fernando Cabrera  [    85] ∎∎∎∎∎∎∎∎∎ (1.23%)
                    Bill Perkins [    85] ∎∎∎∎∎∎∎∎∎ (1.23%)
               Francisco P. Moya [    84] ∎∎∎∎∎∎∎∎∎ (1.21%)
                 Rory I. Lancman [    81] ∎∎∎∎∎∎∎∎∎ (1.17%)
               Ritchie J. Torres [    74] ∎∎∎∎∎∎∎∎ (1.07%)
Public Advocate Jumaane Williams [    73] ∎∎∎∎∎∎∎∎ (1.05%)
                Corey D. Johnson [    71] ∎∎∎∎∎∎∎ (1.02%)
                    Mark Gjonaj  [    69] ∎∎∎∎∎∎∎ (1.00%)
                Chaim M. Deutsch [    63] ∎∎∎∎∎∎∎ (0.91%)
                    Peter A. Koo [    58] ∎∎∎∎∎∎ (0.84%)
             Barry S. Grodenchik [    54] ∎∎∎∎∎∎ (0.78%)
                  Alan N. Maisel [    53] ∎∎∎∎∎ (0.76%)
                  Eric A. Ulrich [    50] ∎∎∎∎∎ (0.72%)
          Rafael L. Espinal, Jr. [    48] ∎∎∎∎∎ (0.69%)
                    Andy L. King [    45] ∎∎∎∎∎ (0.65%)
                James F. Gennaro [    41] ∎∎∎∎ (0.59%)
               Joseph C. Borelli [    35] ∎∎∎ (0.50%)
                 Ruben Diaz, Sr. [    33] ∎∎∎ (0.48%)
             Jumaane D. Williams [    29] ∎∎∎ (0.42%)
                   Steven Matteo [    20] ∎∎ (0.29%)
                  Kevin C. Riley [    15] ∎ (0.22%)
                   Darma V. Diaz [    14] ∎ (0.20%)
        Selvena N. Brooks-Powers [    10] ∎ (0.14%)
 The Public Advocate (Ms. James) [     6]  (0.09%)
                   Eric Dinowitz [     6]  (0.09%)
                    Oswald Feliz [     3]  (0.04%)
```
