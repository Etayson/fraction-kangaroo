# fraction-kangaroo
fractionkangaroo is based on fraction algorithm do the same things as fraction-bsgs but use as solver kangaroo from JeanLucPons.  
Requred kangaroo in the same folder (https://github.com/JeanLucPons/Kangaroo).  
```
Usage:
-pos    [optional] Set number of pos in division cicle in hex format (ex. -pos FF)
-dbit   [required] Set number of divisor 2^ (ex. -dbit 6 mean divisor = 2^6 = 64)
-wl     [optional] Set recovery file from which the state will be loaded
-wt     [optional] Timer interval for saving work (in seconds), default 180
-pb     [required] Set single uncompressed/compressed pubkey for searching
-pk     [required] Range start from
-pke    [required] End range
-maxm   [required] Number of operations before give up the search (maxm*expected operation)
        Note: maxm should be not less than 2
-dp     [required] number of leading zeros for the DP method
-t      [kangaroo settings]
-g      [kangaroo settings]
-gpuid  [kangaroo settings]
-gpu    [kangaroo settings]
Example:
FractionKangaroo.exe -dp 16 -t 0 -gpu -gpuid 0 -g 88,128 -maxm 2 -dbit 6 -pk 80000000000000000000 -pke ffffffffffffffffffff -pb 037e1238f7b1ce757df94faa9a2eb261bf0aeb9f84dbf81212104e78931c2a19dc 
```
If the key is found, the result will be written to a file win.txt  
Purebasic v.5.31 required for compilation 
```
FractionKangaroo.exe -dp 16 -t 0 -gpu -gpuid 0 -g 88,128 -maxm 2 -dbit 6 -pk 80000000000000000000 -pke ffffffffffffffffffff -pb 037e1238f7b1ce757df94faa9a2eb261bf0aeb9f84dbf81212104e78931c2a19dc
-dp 16
-t 0
-gpu
-gpuid 0
-g 88,128
-maxm 2
Divisor set to 2^6
Range begin: 0x80000000000000000000
Range end: 0xffffffffffffffffffff
Pubkey set to 037e1238f7b1ce757df94faa9a2eb261bf0aeb9f84dbf81212104e78931c2a19dc
APP VERSION: FractionKangaroo
Current config hash[56b6ee273fa95b091bb0ff951f6627650717a3cd]
START RANGE= 0000000000000000000000000000000000000000000080000000000000000000
  END RANGE= 00000000000000000000000000000000000000000000ffffffffffffffffffff
WIDTH RANGE= 2^79
Divisor 2^6      0000000000000000000000000000000000000000000000000000000000000040
DIV START RANGE= 0000000000000000000000000000000000000000000002000000000000000000
DIV   END RANGE= 0000000000000000000000000000000000000000000003ffffffffffffffffff
WIDTH RANGE= 2^73

FINDpubkey.c : 037e1238f7b1ce757df94faa9a2eb261bf0aeb9f84dbf81212104e78931c2a19dc
InitFractionX: f4f5086c4adf5d72f97848e135ebea1f7c3231ad2827e12b61b38a0ab54af9d3
InitFractionY: 83b6bfc9fed9c79f3f471d3faca166761c64c129f4afcb311b0c701b0c973503
----------------------------------
Save work every 180 seconds
Position : 0000000000000000000000000000000000000000000000000000000000000000
SearchX  : 57a0cb596743233014e332b551ccf5cf5a2286c8f48de96237a372315a4f6ff5
SerachY  : 99c6c1fd3f768049f74ffe8f599b5efbc442e28fea54d741297700a3c8cc75af
ShiftedX : d880300c91e9553a34c9a225782fa77f76b0c3b21dbff77e4f09f2cfa2528862
ShiftedY : 3a01c5d69925781c1d0b64c77d795f0138076a8403cb61ebee5dae53946f260f
FractionX: f4f5086c4adf5d72f97848e135ebea1f7c3231ad2827e12b61b38a0ab54af9d3
FractionY: 83b6bfc9fed9c79f3f471d3faca166761c64c129f4afcb311b0c701b0c973503
[SOLVER][Kangaroo.exe] programm running..
[SOLVER]params [-t 0 -gpu -gpuId 0 -g 88,128 -d 16 -o test1 -m 2 inkangaroo2.txt]
Kangaroo v2.2
Start:0
Stop :1FFFFFFFFFFFFFFFFFF
Keys :1
Number of CPU thread: 0
Range width: 2^73
Jump Avg distance: 2^36.04
Number of kangaroos: 2^20.46
Suggested DP: 13
Expected operations: 2^37.88
Expected RAM: 159.3MB
DP size: 16 [0xFFFF000000000000]
GPU: GPU #0 NVIDIA GeForce GTX 1660 SUPER (22x64 cores) Grid(88x128) (117.0 MB used)
SolveKeyGPU Thread GPU#0: creating kangaroos...
SolveKeyGPU Thread GPU#0: 2^20.46 kangaroos [6.9s]
[750.36 MK/s][GPU 750.36 MK/s][Count 2^37.72][Dead 0][05:41 (Avg 05:37)][107.2/143.5MB]
Done: Total time 05:50
[SOLVER][Kangaroo.exe] programm finished
Kangaroo finish job
File->Key# 0 [1S]Pub:  0x03D880300C91E9553A34C9A225782FA77F76B0C3B21DBFF77E4F09F2CFA2528862 <--
->03d880300c91e9553a34c9a225782fa77f76b0c3b21dbff77e4f09f2cfa2528862<--
->1a869719b73046d6b46<--
****************************
Solution[]: 0x0000000000000000000000000000000000000000000003a869719b73046d6b46
KEY: 0x00000000000000000000000000000000000000000000ea1a5c66dcc11b5ad180
PUB: 037e1238f7b1ce757df94faa9a2eb261bf0aeb9f84dbf81212104e78931c2a19dc
****************************
Job time 00:05:51s
Total time 00:05:51s
```
