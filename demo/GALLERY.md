# ASCII Chart Gallery

An ASCII counterpart to a chart gallery. Every form below is organized by
the same seven communication goals used by Illustrator's `chart-vocabulary`
skill, so the two compose: pick the goal there, render it here when the
target is a terminal, a log file, a pull request, or a context window.

Figures marked **real** are computed from [`datasets/sales-sample.csv`](../datasets/sales-sample.csv).
Figures marked **illustrative** use shaped data because the sample has no
funnel or process structure; the form is the point, not the numbers.

Regenerate with `pwsh -NoProfile -File demo/build-gallery.ps1`.

| Goal | Forms |
| --- | --- |
| [Comparison](#comparison) | Horizontal bar, Dot plot, Bullet chart, Grouped bar |
| [Change Over Time](#change-over-time) | Sparkline, Column trend, Step line, Small multiples |
| [Proportion](#proportion) | Stacked 100% bar, Percentage rows, Waffle grid |
| [Distribution](#distribution) | Histogram, Box plot |
| [Relationship](#relationship) | Scatter plot, Heatmap |
| [Flow and Process](#flow-and-process) | Funnel, Stage pipeline |
| [Deviation](#deviation) | Diverging bar, Variance column |

## Comparison

### Horizontal bar

Best when ranking items; long labels. Avoid when more than 15 rows. Data: **real**.

```text
Widget A  ##################################  $148,800
Widget B  ######################............   $97,600
```

### Dot plot

Best when precise values in a tight range. Avoid when audience expects bars. Data: **real**.

```text
Jan  o--------------------------------   $36,800
Feb  ---------o-----------------------   $39,000
Mar  ----------------------o----------   $42,300
Apr  ---------------o-----------------   $40,600
May  --------------------------------o   $44,800
Jun  ------------------------o--------   $42,900
```

### Bullet chart

Best when actual against a target. Avoid when no agreed benchmark. Data: **real**.

```text
North  ###########################|##....  107%
South  #######################....|......   83%
```

### Grouped bar

Best when two or three series per category. Avoid when more than three series. Data: **real**.

```text
North
  Widget A #################.............   $83,300
  Widget B ###########...................   $55,800
South
  Widget A #############.................   $65,500
  Widget B ########......................   $41,800
```

## Change Over Time

### Sparkline

Best when inline trend beside a KPI. Avoid when exact values matter more than shape. Data: **real**.

```text
Revenue  //\/\   $36,800 -> $42,900
Months   JFMAMJ
```

### Column trend

Best when discrete periods; magnitude visible. Avoid when many periods (use sparkline). Data: **real**.

```text
                  ##    ##    ##    ##
      ##    ##    ##    ##    ##    ##
      ##    ##    ##    ##    ##    ##
      ##    ##    ##    ##    ##    ##
      ##    ##    ##    ##    ##    ##
      Ja    Fe    Ma    Ap    Ma    Ju   
```

### Step line

Best when values hold then jump. Avoid when smooth continuous change. Data: **real**.

```text
Jan  _________________________|   $36,800
Feb  __________________________|   $39,000
Mar  ____________________________|   $42,300
Apr  ___________________________|   $40,600
May  ______________________________|   $44,800
Jun  _____________________________|   $42,900
```

### Small multiples

Best when comparing trends across categories. Avoid when fewer than four categories. Data: **real**.

```text
North   //\/\    $139,100
South   //\/\    $107,300
```

## Proportion

### Stacked 100% bar

Best when two to four parts of a whole. Avoid when many small slices. Data: **real**.

```text
##################################==========================
North 56.5% South 43.5%
```

### Percentage rows

Best when ranked shares needing exact values. Avoid when shares change over time. Data: **real**.

```text
Widget A  ########################................  60.4%
Widget B  ################........................  39.6%
```

### Waffle grid

Best when part of a whole as countable units. Avoid when precise decimals matter. Data: **real**.

```text
####################
####################
################....
....................
....................
# North 56%   . South 44%
```

## Distribution

### Histogram

Best when shape of a single variable. Avoid when fewer than 20 observations. Data: **real**.

```text
  $6,200  ##########################.... n=6
  $7,980  #################............. n=4
  $9,760  ############################## n=7
 $11,540  #############................. n=3
 $13,320  #################............. n=4
```

### Box plot

Best when spread and outliers at a glance. Avoid when audience unfamiliar with quartiles. Data: **real**.

```text
|---------[=========+==========[------------|
min $6,200   Q1 $8,300   med $10,200   Q3 $12,500   max $15,100
```

## Relationship

### Scatter plot

Best when correlation between two measures. Avoid when more than a few hundred points. Data: **real**.

```text
|                                       * * *
|                                 *   *      
|                            * *             
|                      * * *                 
|                 * *                        
|             ** *                           
|      *   *                                 
|   ***                                      
+--------------------------------------------
units ->                          revenue on y axis
```

### Heatmap

Best when two categorical axes, one measure. Avoid when precise values needed. Data: **real**.

```text
        Jan   Feb   Mar   Apr   May   Jun   
North   ###.. ####. ##### ####. ##### ##### 
South   #.... #.... ##... #.... ##... ##... 
```

## Flow and Process

### Funnel

Best when stage-by-stage drop-off. Avoid when stages are not sequential. Data: **illustrative**.

```text
########################################  Leads      4,000
        ########################  Qualified  2,400
              ###########  Proposal   1,100
                  ####  Won          420
```

### Stage pipeline

Best when steps with hand-offs. Avoid when branching or looping flows. Data: **illustrative**.

```text
[ Ingest ] -> [ Clean ] -> [ Select ] -> [ Render ] -> [ Verify ]
    ok          ok           ok            ok           WARN
```

## Deviation

### Diverging bar

Best when above and below a reference. Avoid when no meaningful midpoint. Data: **real**.

```text
Jan                        ##|                         -$4,267
Feb                         #|                         -$2,067
Mar                          |#                        +$1,233
Apr                          |                         -$467
May                          |##                       +$3,733
Jun                          |#                        +$1,833
```

### Variance column

Best when actual against plan per period. Avoid when no plan exists. Data: **real**.

```text
Jan    $36,800  vs avg   $41,067     -4,267  [UNDER]
Feb    $39,000  vs avg   $41,067     -2,067  [UNDER]
Mar    $42,300  vs avg   $41,067     +1,233  [OK]  
Apr    $40,600  vs avg   $41,067       -467  [UNDER]
May    $44,800  vs avg   $41,067     +3,733  [OK]  
Jun    $42,900  vs avg   $41,067     +1,833  [OK]  
```

