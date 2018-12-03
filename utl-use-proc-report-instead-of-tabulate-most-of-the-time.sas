Use proc report instead of tabulate most of the time

  1. Report can output a dataset that is congruent with the printer report.
  2. You can use equations (almost like a datastep)
  3. Supports MLF
  4. Can sort, transpose and summarize.

 You ar emuch less likely to paint yourself in a corner with 'proc report'.
 Expecially because report output a congruent sas dataset


github
https://tinyurl.com/yag5fkdc
https://github.com/rogerjdeangelis/utl-use-proc-report-instead-of-tabulate-most-of-the-time

SAS Forum
https://tinyurl.com/yc3e7r8k
https://communities.sas.com/t5/New-SAS-User/Create-table-of-multiple-variables/m-p/516917#M3254


INPUT
=====
                         |  RULES
 WORK.HAVE total obs=50  |
                         |
  MON    TYM     TMP     |
                         |
  oct    noon    cool    |                ** Summary Noon    **
  oct    noon    frze    |
  oct    noon    frze    |  OCT_FRZE = 2  OCT_NOTWARM = sum(cool,cold,frze) =3

  oct    evng    cold    |
  oct    evng    cold    |
  oct    evng    cold    |
  oct    evng    cold    |                 ** Summary Evening  **
  oct    evng    cool    |
  oct    evng    cool    |  OCT_FRZE = .   OCT_NOTWARM = sum(coil,cold,frze) =6

  oct    morn    cold    |
  oct    morn    cold    |
  oct    morn    cold    |
  oct    morn    cool    |
  oct    morn    cool    |


EXAMPLE OUTPUT
--------------

WORK.WANT total obs=4

                         DEC_                   NOV_                   OCT_
   TYM     DEC_FRZE    NOTWARM    NOV_FRZE    NOTWARM    OCT_FRZE    NOTWARM

  noon         3           5          .           5          2           3
  evng         2           7          3           6          .           6
  morn         3           6          .           7          .           5

  TOTAL        8          18          3          18          2          14


PROCESS
=======

proc format library=work;

  value $coldtemp (multilabel)

      'cool','cold','frze'= 'notwarm'
      'frze' = 'frze';

run;quit;

* only interested in the output dataset;

proc report data=have out=want (drop=_break_ rename=(%utl_renamel(

  _C2_ _C3_ _C4_ _C5_ _C6_ _C7_ ,
  dec_frze dec_notwarm nov_frze nov_notwarm oct_frze oct_notwarm)));

cols tym mon, tmp;

define tym / group;
define mon / across;
define tmp / across format=$coldtemp. mlf;

rbreak after /summarize;
   compute after;
         tym='TOTAL';
   endcomp;

run;quit;


OUTPUT
======
see above

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have(where=(tmp ne 'warm'));
 input MON$ TYM$ TMP$ @@;
cards4;
oct noon cool oct noon frze oct noon frze oct noon warm oct noon warm oct noon
warm oct noon warm oct evng cold oct evng cold oct evng cold oct evng cold oct
evng cool oct evng cool oct evng warm oct morn cold oct morn cold oct morn cold
oct morn cool oct morn cool oct morn warm oct morn warm oct morn warm nov noon
cold nov noon cold nov noon cold nov noon cold nov noon cold nov noon warm nov
noon warm nov evng cool nov evng cool nov evng cool nov evng frze nov evng frze
nov evng frze nov morn cold nov morn cold nov morn cool nov morn cool nov morn
cool nov morn cool nov morn cool dec noon cold dec noon cold dec noon frze dec
noon frze dec noon frze dec evng cold dec evng cold dec evng cool dec evng cool
dec evng cool dec evng frze dec evng frze dec morn cold dec morn cold dec morn
cold dec morn frze dec morn frze dec morn frze
;;;;
run;quit;


