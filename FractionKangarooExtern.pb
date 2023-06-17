EnableExplicit
IncludeFile "lib\Curve64.pb"
CompilerIf #PB_Compiler_Unicode
  Debug" switch to Ascii mode"
  End
CompilerEndIf
CompilerIf Not #PB_Compiler_Processor = #PB_Processor_x64
  Debug" only x64 processor support"
  End
CompilerEndIf
#MB=1048576
#GB=1073741824
#array_dim=64
#line_dim=64
#alignMemoryGpu=64   
#LOGFILE=1
#WINFILE="win.txt"
#appver="FractionKangaroo"
#JOBFILE=33
#File=777
#HEADERSIZE=156
Structure JobSturucture
  *arr
  *NewPointsArr
  beginrangeX$
  beginrangeY$
  totalpoints.i  
  pointsperbatch.i
  isAlive.i
  isError.i  
  Yoffset.i
  beginNumberPoint.i
EndStructure

Structure sortjobStructure
  *ptarr
  *sortptarray
  totallines.i
  curpos.i
EndStructure

Structure comparsationStructure
  pos.i
  direction.i
EndStructure

Structure settingsStructure
  startrange.s
  endrange.s
  keyX.s
  keyY.s
  nkang.i
  maxm.d
  file$
  programmname.s
  getworkrangeBegin.s
  getworkrangeEnd.s
  getworkPub.s
  getworkDP.i
  jobfilename.s
  jobsaveinterval.i
EndStructure

Structure kangarooStructure
  params$
EndStructure

Structure CoordPoint
  *x
  *y
EndStructure
#helpsize = 4096
#align_size=128
#HashTablesz=4;4B counter items
#Pointersz=8
#HashTableSizeHash=4
#HashTableSizeItems=8
#maximumgpucount = 32

Structure HashTableResultStructure   
 size.l
 *contentpointer
EndStructure

Define TableMutex
Define cls$=RSet(cls$,80,Chr(8))
TableMutex = CreateMutex()


Define *CurveP, *CurveGX, *CurveGY, *Curveqn
*CurveP = Curve::m_getCurveValues()
*CurveGX = *CurveP+32
*CurveGY = *CurveP+64
*Curveqn = *CurveP+96

Global Dim a$(7)
Global Dim gpu(#maximumgpucount)
a$(0)="MAX_THREADS_PER_BLOCK "
a$(1)="SHARED_SIZE_BYTES "
a$(2)="CONST_SIZE_BYTES "
a$(3)="LOCAL_SIZE_BYTES "
a$(4)="NUM_REGS "
a$(5)="PTX_VERSION "
a$(6)="BINARY_VERSION" 
Define recovery=0
Define recoveryCNT$
Define recoverypos$
Define recoveryfilename$
Define recoverypub$
Define recoveryfraction$
Define recoveryfingerprint$
Define cnttimer=180
Define settingsvalue$, settingsFingerPrint$
Define cls$

Define.s Gx , Gy, p, privkey, privkeyend, pball$, walletall$, mainpub, addpubs

Define totallaunched

Define keyMutex, quit
Define *PrivBIG, PubkeyBIG.CoordPoint, *MaxNonceBIG, FINDPUBG.CoordPoint, ADDPUBG.CoordPoint, *bufferResult, *addX, *addY, *PRKADDBIG, PUBADDBIG.CoordPoint, REALPUB.CoordPoint, *WINKEY, Two.CoordPoint
Define *WidthRange
Define Defdevice$,  endrangeflag=0, pubfile$="", globalquit, isreadyjob,  allbabypoint
Define JobMutex
Define *GlobKey
Define GlobPub.CoordPoint
Define *OneBig
Define *high, divisorBit = 6, *Divisor, tg_botid$ , tg_myid$ 
Define CurrentFRACTION.CoordPoint, *CurrentFRACTIONNegY, FRACTIONBIG.CoordPoint, DIVPUPBIG.CoordPoint, *CurElement, listpos$, curentpos$="0", iscopy, totalgpulaunched
JobMutex = CreateMutex()
keyMutex = CreateMutex()
Define NewMap settings.settingsStructure()
Define kangarooparams.kangarooStructure
Define CompilerKangaroo, fpub$


;puzzle #80(79bit)
privkey.s = "80000000000000000000"
privkeyend.s = "ffffffffffffffffffff"
mainpub.s = "037e1238f7b1ce757df94faa9a2eb261bf0aeb9f84dbf81212104e78931c2a19dc" 

;puzzle #125 (124bit)              
;privkey.s =    "10000000000000000000000000000000"
;privkeyend.s = "1fffffffffffffffffffffffffffffff"
;mainpub.s = "0233709eb11e0d4439a729f21c2c443dedb727528229713f0065721ba8fa46f00e"

OpenConsole()
Declare.s getprogparam()
Declare exit(str.s)
Declare Log2(Quad.q)


kangarooparams\params$ = getprogparam()


Macro move16b_1(offset_target_s,offset_target_d)  
  !movdqa xmm0,[rdx++offset_target_s]
  !movdqa [rcx+offset_target_d],xmm0
EndMacro

Macro move32b_(s,d,offset_target_s,offset_target_d)
  !mov rdx, [s]
  !mov rcx, [d]  
  move16b_1(0+offset_target_s,0+offset_target_d)
  move16b_1(16+offset_target_s,16+offset_target_d) 
EndMacro

Procedure toLittleInd32(*a)
  !mov rsi,[p.p_a]  
  !mov eax,[rsi]
  !mov ecx,[rsi+4]
  !bswap eax
  !mov [rsi],eax
  !bswap ecx
  !mov [rsi+4],ecx  
EndProcedure

Procedure toLittleInd32_64(*a)
  !mov rsi,[p.p_a]  
  !mov eax,[rsi]
  !mov ecx,[rsi+4]
  !bswap eax
  !mov [rsi+4],eax
  !bswap ecx
  !mov [rsi],ecx  
EndProcedure

#INTERNET_DEFAULT_HTTP_PORT = 80
#INTERNET_DEFAULT_HTTPS_PORT = 443

#INTERNET_OPEN_TYPE_DIRECT = 1
#INTERNET_OPEN_TYPE_PROXY = 3

#INTERNET_SERVICE_HTTP = 3

#INTERNET_FLAG_PRAGMA_NOCACHE =           $00000100
#INTERNET_FLAG_IGNORE_CERT_CN_INVALID =   $00001000
#INTERNET_FLAG_IGNORE_CERT_DATE_INVALID = $00002000
#INTERNET_FLAG_NO_COOKIES =               $00080000
#INTERNET_FLAG_NO_AUTO_REDIRECT =         $00200000
#INTERNET_FLAG_SECURE =                   $00800000
#INTERNET_FLAG_DONT_CACHE =               $04000000


#HTTP_ADDREQ_FLAG_ADD =     $20000000
#HTTP_ADDREQ_FLAG_REPLACE = $80000000


#ERROR_INTERNET_INVALID_CA = 12045

#INTERNET_OPTION_SECURITY_FLAGS = 31

#SECURITY_FLAG_IGNORE_UNKNOWN_CA = $00000100


Procedure.s do_request(host.s,port, page.s="", post_data.s="",  cookie.s="", is_secure.i=#False, user_agent.s="", referer.s="", proxy.s="", timeout.l=1000, redirect.i=#True)
 
  Protected.l flags, bytes_read, dwFlags, dwBuffLen
  Protected.i open_handle, connect_handle, request_handle, send_handle, Ok, access_type, LastError
  Protected.s verb, headers, buffer, result
 
  
  If proxy = "" : access_type =  #INTERNET_OPEN_TYPE_DIRECT : Else : access_type = #INTERNET_OPEN_TYPE_PROXY : EndIf
  If user_agent = "" : user_agent = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)" : EndIf
  open_handle = InternetOpen_(user_agent, access_type, "", "", 0)
 
  InternetSetOption_(open_handle, 2, timeout, 4)
 
  flags = #INTERNET_FLAG_PRAGMA_NOCACHE
  flags | #INTERNET_FLAG_NO_COOKIES
  flags | #INTERNET_FLAG_DONT_CACHE
 
  If is_secure
    port = #INTERNET_DEFAULT_HTTPS_PORT
   
    flags | #INTERNET_FLAG_SECURE
    flags | #INTERNET_FLAG_IGNORE_CERT_CN_INVALID
    flags | #INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
  Else
    If port=0
      port = #INTERNET_DEFAULT_HTTP_PORT
    EndIf
  EndIf
 
  
  connect_handle = InternetConnect_(open_handle, host, port, "", "", #INTERNET_SERVICE_HTTP, 0, 0)
  
 
  If Not redirect : flags | #INTERNET_FLAG_NO_AUTO_REDIRECT : EndIf
  If post_data = "" : verb = "GET" : Else : verb = "POST" : EndIf
  
  If page = "" : page = "/" : EndIf
  
  request_handle = HttpOpenRequest_(connect_handle, verb, page, "", referer, #Null, flags, 0)
 
  
  If verb = "POST"
    ;headers = "Content-Type: application/x-www-form-urlencoded" + #CRLF$
    headers = "Content-Type: application/json; charset=UTF-8" + #CRLF$
    HttpAddRequestHeaders_(request_handle, headers, Len(headers), #HTTP_ADDREQ_FLAG_ADD | #HTTP_ADDREQ_FLAG_REPLACE)
  EndIf
  If cookie <> ""
    headers = "Cookie: "+ cookie + #CRLF$
    HttpAddRequestHeaders_(request_handle, headers, Len(headers), #HTTP_ADDREQ_FLAG_ADD | #HTTP_ADDREQ_FLAG_REPLACE)
  EndIf
 
 
  Ok = 0
  Repeat
    send_handle = HttpSendRequest_(request_handle, #Null, 0, post_data, Len(post_data))
   
    If send_handle = 0
      LastError = GetLastError_()
     
      Debug ( "[doRerquest] Error " + Str(LastError))
     
      If LastError = #ERROR_INTERNET_INVALID_CA
       
        dwBuffLen = SizeOf(dwFlags)
       
        InternetQueryOption_(request_handle, #INTERNET_OPTION_SECURITY_FLAGS, @dwFlags, @dwBuffLen)
       
        dwFlags | #SECURITY_FLAG_IGNORE_UNKNOWN_CA
        InternetSetOption_(request_handle, #INTERNET_OPTION_SECURITY_FLAGS, @dwFlags, SizeOf(dwFlags))
        Ok + 1
      Else
        Ok = 2
      EndIf
    Else
      Ok = 2
    EndIf
  Until Ok = 2
 
 
  buffer = Space(1024)
  Repeat
    InternetReadFile_(request_handle, @buffer, 1024, @bytes_read)
    result + Left(buffer, bytes_read)
    buffer = Space(1024)
  Until bytes_read = 0
 
  InternetCloseHandle_(open_handle)
  InternetCloseHandle_(connect_handle)
  InternetCloseHandle_(request_handle)
  InternetCloseHandle_(send_handle)
 
  ProcedureReturn result
 
EndProcedure

Procedure.s commpressed2uncomressedPub(ha$)
  Protected y_parity, ruc$, x$, a$, *a, *res
  Shared *CurveP
  *a = AllocateMemory(64)  
  *res=*a + 32  
  
  y_parity = Val(Left(ha$,2))-2
  x$ = Right(ha$,Len(ha$)-2)
  
  a$=RSet(x$, 64,"0")
  Curve::m_sethex32(*a, @a$)  
  Curve::m_YfromX64(*res,*a, *CurveP)  
  
  If PeekB(*res)&1<>y_parity
    Curve::m_subModX64(*res,*CurveP,*res,*CurveP)
  EndIf
  
  ruc$ = Curve::m_gethex32(*res)
  
  FreeMemory(*a)
  ProcedureReturn x$+ruc$

EndProcedure

Procedure.s uncomressed2commpressedPub(ha$)
  Protected Str1.s, Str2.s, x$,y$,ru$,rc$
  ha$=LCase(ha$)
  If Left(ha$,2)="04" And Len(ha$)=130
    ha$=Right(ha$,Len(ha$)-2)
  EndIf
  Str1=Left(ha$,64)
  Str2=Right(ha$,64)
  Debug Str1
  Debug Str2
  
  x$=PeekS(@Str1,-1,#PB_Ascii)
  x$=RSet(x$,64,"0")
  y$=PeekS(@Str2,-1,#PB_Ascii)
  y$=RSet(y$,64,"0")
  ru$="04"+x$+y$
  If FindString("13579bdf",Right(y$,1))>0
    rc$="03"+x$
  Else
    rc$="02"+x$
  EndIf
  
  ProcedureReturn rc$

EndProcedure


Procedure Log2(Quad.q)
Protected Result
   While Quad <> 0
      Result + 1
      Quad>>1
   Wend
   ProcedureReturn Result-1
 EndProcedure
 
Procedure ValueL(*a)
  !mov rbx,[p.p_a]   
  !mov eax,[rbx]  
ProcedureReturn
EndProcedure

Procedure INCvalue32(*a)
  !mov rsi,[p.p_a]  
  !mov eax,[rsi]
  !inc eax 
  !mov [rsi],eax  
EndProcedure

Procedure swap8(*a)
  !mov rsi,[p.p_a]  
  !mov eax,[rsi]
  !mov ecx,[rsi+4]  
  !mov [rsi+4],eax
  !mov [rsi],ecx  
EndProcedure

Procedure swap32(*a)
  !mov rsi,[p.p_a]  
  !mov eax,[rsi+24]
  !mov ecx,[rsi+4]
  !mov [rsi+4],eax
  !mov [rsi+24],ecx 
  
  !mov rsi,[p.p_a]  
  !mov eax,[rsi+28]
  !mov ecx,[rsi]
  !mov [rsi],eax
  !mov [rsi+28],ecx 
  
  !mov rsi,[p.p_a]  
  !mov eax,[rsi+20]
  !mov ecx,[rsi+8]
  !mov [rsi+8],eax
  !mov [rsi+20],ecx 
  
  !mov rsi,[p.p_a]  
  !mov eax,[rsi+16]
  !mov ecx,[rsi+12]
  !mov [rsi+12],eax
  !mov [rsi+16],ecx 
EndProcedure

Procedure m_check_less_more_equilX8(*s,*t); 0 - s = t, 1- s < t, 2- s > t
  !mov rsi,[p.p_s]  
  !mov rdi,[p.p_t]
  
    
  !xor cx,cx
  !llm_check_less_continueQ:
  
  !mov rax,[rsi]
  !mov rbx,[rdi]
   
  !cmp rax,rbx
  !jb llm_check_less_exit_lessQ
  !ja llm_check_less_exit_moreQ 
  
  !xor rax,rax
  !jmp llm_check_less_exitQ  
  
  !llm_check_less_exit_moreQ:
  !mov rax,2
  !jmp llm_check_less_exitQ  
  
  !llm_check_less_exit_lessQ:
  !mov rax,1
  !llm_check_less_exitQ:
ProcedureReturn  
EndProcedure

Procedure check_equil(*s,*t,len=8)
  !mov rsi,[p.p_s]  
  !mov rdi,[p.p_t]
  !xor cx,cx
  !ll_check_equil_continue:
  
  !mov eax,[rsi]
  !mov ebx,[rdi]
  !add rsi,4
  !add rdi,4
  !bswap eax
  !bswap ebx
  !cmp eax,ebx
  !jne ll_check_equil_exit_noteqil
  !inc cx 
  !cmp cx,[p.v_len]
  !jb ll_check_equil_continue
  
  !mov eax,1
  !jmp ll_check_equil_exit  
  
  !ll_check_equil_exit_noteqil:
  !mov eax,0
  !ll_check_equil_exit:
ProcedureReturn  
EndProcedure


Procedure div8(*s,n,*q,*r);8 byte / n> *q, *r
  !mov rsi,[p.p_s]   
  !xor rdx,rdx
  !mov rax,[rsi]
  !mov rbx,[p.v_n]
  !div rbx
  !mov rsi,[p.p_r]   
  !mov [rsi],rdx
  !mov rsi,[p.p_q] 
  !mov [rsi],rax
  
ProcedureReturn  
EndProcedure

Procedure sub8(*a,*b,*c);8 byte a-b> c
  !mov rsi,[p.p_a]  
  !mov rax,[rsi]
  !mov rdi,[p.p_b]
  !sub rax,[rdi]
  !mov rsi,[p.p_c] 
  !mov [rsi],rax
  
ProcedureReturn  
EndProcedure

Procedure add8(*a,*b,*c);8 byte a+b> c
  !mov rsi,[p.p_a]  
  !mov rax,[rsi]
  !mov rdi,[p.p_b]
  !add rax,[rdi]
  !mov rsi,[p.p_c] 
  !mov [rsi],rax
  
ProcedureReturn  
EndProcedure

Procedure add8ui(*a,n,*c);8 byte a+b> c
  !mov rsi,[p.p_a]  
  !mov rax,[rsi]
  !add rax,[p.v_n]
  !mov rsi,[p.p_c] 
  !mov [rsi],rax
  
ProcedureReturn  
EndProcedure

Procedure mul8ui(*s,n,*q);8 byte * n
  !mov rsi,[p.p_s]   
  !mov rax,[rsi]  
  !mov rbx,[p.v_n]
  !mul rbx
  !mov rsi,[p.p_q] 
  !mov [rsi],rax
  
ProcedureReturn  
EndProcedure

Procedure deserialize(*a,b,*sptr,counter=32);fron hex
  Protected *ptr
    *ptr=*a+64*b  
  
  !mov rbx,[p.p_ptr] ;ebx > rbx
  !mov rdi,[p.p_sptr] ;edi > rdi  
  
  !xor cx,cx  
  !ll_MyLabelf:
  
  !push cx
  !mov eax,[rdi]
  !mov ecx,eax
  !xor edx,edx
  
   
  !sub al,48  
  !cmp al,15     
  !jb ll_MyLabelf1        
  !sub al,7
  
  !ll_MyLabelf1:
  !and al,15      ;1
  !or dl,al  
  !rol edx,4
  !ror ecx,8
  !mov al,cl
  
  !sub al,48  
  !cmp al,15     
  !jb ll_MyLabelf2        
  !sub al,7
  
  !ll_MyLabelf2:
  !and al,15      ;2
  !or dl,al  
  !rol edx,4
  !ror ecx,8
  !mov al,cl
  
  !sub al,48  
  !cmp al,15     
  !jb ll_MyLabelf3        
  !sub al,7
  
  !ll_MyLabelf3:
  !and al,15      ;3
  !or dl,al  
  !rol edx,4
  !ror ecx,8
  !mov al,cl
  
  !sub al,48  
  !cmp al,15     
  !jb ll_MyLabelf4        
  !sub al,7
  
  !ll_MyLabelf4:
  !and al,15      ;4
  !or dl,al  
  
  !ror dx,8
  !mov [rbx],dx
  !add rdi,4
  !add rbx,2
  
  
  !pop cx   
  !inc cx 
  !cmp cx,[p.v_counter]
  !jb ll_MyLabelf 
  
  

EndProcedure

Procedure serialize(*a,b,*sptr,counter=32);>hex  
 Protected *ptr
  *ptr=*a+#array_dim*b  
  
  !mov rbx,[p.p_ptr] ;ebx > rbx
  !mov rdi,[p.p_sptr] ;edi > rdi
  
  !xor cx,cx
  !ll_MyLabel:
  
  !push cx
  
  !mov ax,[rbx]
  !xor edx,edx
  
  !mov cx,ax
  
  !and ax,0fh
  !cmp al,10     ;1
  !jb ll_MyLabel1        
  !add al,39
  
  !ll_MyLabel1:
  !add al,48   
  !or dx,ax
  !shl edx,8
  
  !ror cx,4
  !mov ax,cx
  
  !and ax,0fh
  !cmp al,10     ;2
  !jb ll_MyLabel2        
  !add al,39
  
  !ll_MyLabel2:
  !add al,48   
  !or dx,ax

  !shl edx,8
  
  !ror cx,4
  !mov ax,cx
  
  !and ax,0fh
  !cmp al,10     ;3
  !jb ll_MyLabel3        
  !add al,39
  
  !ll_MyLabel3:
  !add al,48   
  !or dx,ax
  !shl edx,8
  
  !ror cx,4
  !mov ax,cx
  
  !and ax,0fh
  !cmp al,10     ;4
  !jb ll_MyLabel4        
  !add al,39
  
  !ll_MyLabel4:
  !add al,48   
  !or dx,ax
  !ror edx,16
  !mov [rdi],edx
  !add rdi,4
  !add rbx,2
  
  !pop cx
  !inc cx
  !cmp cx,[p.v_counter]; words
  !jb ll_MyLabel 
EndProcedure

Procedure exit(a$)
  PrintN(a$)
  PrintN("Press Enter to exit")
  Input()
  CloseConsole()
  End
EndProcedure


Procedure.s cutHex(a$)
  a$=Trim(UCase(a$)) 
  If Left(a$,2)="0X" 
    a$=Mid(a$,3,Len(a$)-2)
  EndIf 
  If Len(a$)=1
    a$="0"+a$
  EndIf
ProcedureReturn LCase(a$)
EndProcedure

Procedure.s getprogparam()
  Protected parametrscount, datares$, i, walid, params$
  Shared  privkey, privkeyend
  Shared mainpub, pubfile$, recovery, recoveryfilename$, cnttimer, divisorBit, curentpos$, tg_botid$ , tg_myid$, settings()
  parametrscount=CountProgramParameters()
  
  i=0
  While i<parametrscount  
    Select LCase(ProgramParameter(i))      
        Case "-botid"
           Debug "found -dbit"
           i+1   
           datares$ = ProgramParameter(i) 
           If datares$<>"" And Left(datares$,1)<>"-"  
             tg_botid$ = datares$            
             PrintN( "botid: "+tg_botid$)
           EndIf
        Case "-myid"
           Debug "found -dbit"
           i+1   
           datares$ = ProgramParameter(i) 
           If datares$<>"" And Left(datares$,1)<>"-"  
             tg_myid$ = datares$            
             PrintN( "myid: "+tg_myid$)
           EndIf   
        Case "-pos"
           Debug "found -dbit"
           i+1   
           datares$ = ProgramParameter(i) 
           If datares$<>"" And Left(datares$,1)<>"-"  
             curentpos$ = datares$            
             PrintN( "Position set to "+curentpos$)
           EndIf
         Case "-dbit"
           Debug "found -dbit"
           i+1   
           datares$ = ProgramParameter(i) 
           If datares$<>"" And Left(datares$,1)<>"-"  
             divisorBit = Val(datares$)             
             PrintN( "Divisor set to 2^"+Str(divisorBit))
           EndIf
           
         Case "-wl"
        Debug "found -wl"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          recoveryfilename$ = datares$    
          recovery=1
          PrintN( "Recovery work file: "+recoveryfilename$)
         EndIf
      Case "-wt"
        Debug "found -wt"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          cnttimer = Val(datares$)
          If cnttimer<30
            cnttimer=30
          EndIf
          PrintN( "Saving timer every "+Str(cnttimer)+" seconds")
        EndIf  
       Case "-pb"
        Debug "found -pb"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          mainpub=LCase(cutHex(datares$))
          PrintN( "Pubkey set to "+mainpub)
          walid + 1
        EndIf
              
       Case "-pk"
        Debug "found -pk"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          privkey=LCase(cutHex(datares$))
          PrintN( "Range begin: 0x"+privkey)         
        EndIf 
        
       Case "-pke"
        Debug "found -pke"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          privkeyend=LCase(cutHex(datares$))
          PrintN( "Range end: 0x"+privkeyend)         
        EndIf   
        ;kangaroo settings
        
      Case "-maxm"
        Debug "found -maxm"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          settings("1")\maxm = ValD(datares$)    
          PrintN("-maxm "+StrD(settings()\maxm))
        EndIf  
      Case "-dp"
        Debug "found -dp"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          settings("1")\getworkDP = Val(datares$)    
          PrintN("-dp "+Str(settings()\getworkDP))
        EndIf
       Case "-nkang"
        Debug "found -nkang"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          settings("1")\nkang = Val(datares$)    
          PrintN("-nkang "+Str(settings()\nkang))
         EndIf
      Case "-t"
        Debug "found -t"
        i+1   
        datares$ = ProgramParameter(i) 
        If datares$<>"" And Left(datares$,1)<>"-"  
          params$ +"-t "+ Str(Val(datares$))+" "       
           PrintN("-t "+Str(Val(datares$)))
         EndIf
         
      Case "-g"
        Debug "found -g"
        i+1             
        datares$ = ProgramParameter(i)
        If datares$<>"" And Left(datares$,1)<>"-"
          params$ +"-g "+ Trim(datares$)+" "
          PrintN("-g "+Trim(datares$))
        EndIf
       Case "-gpuid"
        Debug "found -gpuid"
        i+1             
        datares$ = ProgramParameter(i)
        If datares$<>"" And Left(datares$,1)<>"-"
          params$ +"-gpuId "+ Trim(datares$)+" "
          PrintN("-gpuid "+Trim(datares$))
        EndIf
      Case "-gpu"
        Debug "found -gpu"        
        params$ +"-gpu "
        PrintN("-gpu ")
      
        
       
        
      Default
        exit("Unknown parameter ["+ProgramParameter(i)+"]")
    EndSelect
    
    


    i+1 
  Wend
ProcedureReturn params$
EndProcedure

Procedure check_less_more_equil(*s,*t,len=8);0 - s = t, 1- s < t, 2- s > t
  !mov rsi,[p.p_s]  
  !mov rdi,[p.p_t]
  !xor cx,cx
  !ll_check_less_continue:
  
  !mov eax,[rsi]
  !mov ebx,[rdi]
  !add rsi,4
  !add rdi,4
  !bswap eax
  !bswap ebx
  !cmp eax,ebx
  !jb ll_check_less_exit_less
  !ja ll_check_less_exit_more  
  !inc cx 
  !cmp cx,[p.v_len]
  !jb ll_check_less_continue
  
  !mov eax,0
  !jmp ll_check_less_exit  
  
  !ll_check_less_exit_more:
  !mov eax,2
  !jmp ll_check_less_exit  
  
  !ll_check_less_exit_less:
  !mov eax,1
  !ll_check_less_exit:
ProcedureReturn  
EndProcedure





Procedure.s m_gethex8(*bin)  
  Protected *sertemp=AllocateMemory(16, #PB_Memory_NoClear)
  Protected res$  
  ;************************************************************************
  ;Convert bytes in LITTLE indian format to HEX string in BIG indian format
  ;************************************************************************ 
  Curve::m_serializeX64(*bin,0,*sertemp,2)  
  res$=PeekS(*sertemp,16, #PB_Ascii)
  FreeMemory(*sertemp)
ProcedureReturn res$
EndProcedure

Procedure prntarrBIG(*arr, linestotal, offset=96)
  
  Protected i
  
  For i = 0 To linestotal-1
    
    PrintN("["+Str(i)+"]"+Curve::m_gethex32(*arr+i*offset))
  Next i
  PrintN("")
EndProcedure




Procedure.s getStrfrombin(*pointlocation,lenbytes=32)
  Protected resser.s=Space(lenbytes*4)
  serialize(*pointlocation,0,@resser,lenbytes/2)
  ProcedureReturn PeekS(@resser,lenbytes*2)
EndProcedure



Procedure check_LME32bit(*s,*t)
  !mov rsi,[p.p_s]  
  !mov rdi,[p.p_t]
    
  !mov eax,[rsi]
  !cmp eax,[rdi]
  !jb llm_LME32bit_exit_less
  !ja llm_LME32bit_exit_more  
   
  !xor eax,eax
  !jmp llm_LME32bit_exit  
  
  !llm_LME32bit_exit_more:
  !mov eax,2
  !jmp llm_LME32bit_exit  
  
  !llm_LME32bit_exit_less:
  !mov eax,1
  !llm_LME32bit_exit:
ProcedureReturn  
EndProcedure



Procedure randomInRange(*res, *re)
  Shared *CurveGX, *CurveGY, *CurveP
  Protected a$
  Protected *ax = AllocateMemory(96), *ay = *ax+32 
  
  a$=RSet(Hex(Random(9223372036854775800,1)), 64,"0")
  Curve::m_sethex32(*res, @a$)
  Curve::m_PTMULX64(*ax, *ay, *CurveGX, *CurveGY, *res,*CurveP)
  a$=RSet(Hex(Random(9223372036854775800,1)), 64,"0")
  Curve::m_sethex32(*res, @a$)  
  Curve::m_PTMULX64(*ax, *ay, *ax, *ay, *res,*CurveP)
  
  Curve::m_reminderX64(*res, *ax, *re)  
  FreeMemory(*ax)
EndProcedure

Procedure saveCurentCNT(gpcount)
  Protected lastsavigdate = Date(), a$
  Shared globalquit, JobMutex, cnttimer, settingsFingerPrint$, *CurElement, REALPUB\x, REALPUB\y, CurrentFRACTION\x, CurrentFRACTION\y
  
  Repeat
    If Date() - lastsavigdate>cnttimer
     
      If CreateFile(1, "currentwork.temp",#PB_File_NoBuffering) 
        ;save pos
        WriteStringN(1,Curve::m_gethex32(*CurElement)) 
        ;savepubkey
        a$ = uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y))
        WriteStringN(1,a$)
        ;save fraction
        a$ = uncomressed2commpressedPub(Curve::m_gethex32(CurrentFRACTION\x)+ Curve::m_gethex32(CurrentFRACTION\y))
        WriteStringN(1,a$)        
        WriteStringN(1,settingsFingerPrint$)         
        CloseFile(1)
        DeleteFile("currentwork.txt")
          If RenameFile("currentwork.temp", "currentwork.txt")
            
          EndIf
        
      Else
        ;exit("Can`t create the file!")
      EndIf
      lastsavigdate = Date()
    EndIf
    Delay(5000)
  Until globalquit
EndProcedure

Procedure RecoverFromPos()
  Shared DIVPUPBIG, REALPUB, *CurElement, FRACTIONBIG, *CurveP, CurrentFRACTION, *CurrentFRACTIONNegY
  If Curve::m_check_nonzeroX64(*CurElement)
    ;idx>0
    
    Curve::m_PTMULX64(CurrentFRACTION\x, CurrentFRACTION\y, FRACTIONBIG\x, FRACTIONBIG\y, *CurElement,*CurveP)
    Curve::m_subModX64(*CurrentFRACTIONNegY,*CurveP,CurrentFRACTION\y,*CurveP)
    Curve::m_ADDPTX64(REALPUB\x, REALPUB\y, DIVPUPBIG\x, DIVPUPBIG\y, CurrentFRACTION\x, *CurrentFRACTIONNegY, *CurveP)
    
    Curve::m_ADDPTX64(CurrentFRACTION\x, CurrentFRACTION\y, CurrentFRACTION\x, CurrentFRACTION\y, FRACTIONBIG\x, FRACTIONBIG\y, *CurveP)
  EndIf
EndProcedure

Procedure.s getElem(js.i,pname.s="",pelem.l=0,aelem.l=0)
  Protected result$,jsFloat_g
  
  result$=""
  If IsJSON(js) And GetJSONMember(JSONValue(js), pname)
  Select JSONType(GetJSONMember(JSONValue(js), pname))
      
      Case #PB_JSON_String
          result$= GetJSONString(GetJSONMember(JSONValue(js), pname))          
        Case #PB_JSON_Array
         
              
              
       If JSONArraySize(GetJSONMember(JSONValue(js), pname))>pelem
         Select JSONType(GetJSONElement(GetJSONMember(JSONValue(js), pname), pelem))
           Case #PB_JSON_String
             result$= GetJSONString(GetJSONElement(GetJSONMember(JSONValue(js), pname), pelem))
           Case #PB_JSON_Number            
             result$= Str(GetJSONInteger(GetJSONElement(GetJSONMember(JSONValue(js), pname), pelem)))    
             jsFloat_g=GetJSONDouble(GetJSONElement(GetJSONMember(JSONValue(js), pname), pelem))
             
           Case #PB_JSON_Array
             If JSONArraySize(GetJSONElement(GetJSONMember(JSONValue(js), pname), pelem))>aelem             
                result$+ GetJSONString(GetJSONElement(GetJSONElement(GetJSONMember(JSONValue(js), pname), pelem),aelem))
             EndIf
          Case #PB_JSON_Boolean
             result$=Str(GetJSONBoolean(GetJSONElement(GetJSONMember(JSONValue(js), pname), pelem)))
             
         EndSelect
          
        EndIf
        
      Case #PB_JSON_Boolean
        result$=Str(GetJSONBoolean(GetJSONMember(JSONValue(js), pname)))
        
        
      Case #PB_JSON_Number
        
        result$= Str(GetJSONInteger(GetJSONMember(JSONValue(js), pname)))

        
    EndSelect
  
  EndIf

  ProcedureReturn result$
EndProcedure

Procedure makehook(text$)
  Protected answer$, resultanswer, pars_res_send,page$, answerdo$
  Shared tg_botid$ , tg_myid$ 
  If tg_botid$<>"" And tg_myid$<>""
    Repeat        
      page$ =tg_botid$+"/sendMessage?chat_id="+tg_myid$+"&text="+text$          
      answerdo$ = do_request("api.telegram.org",0,page$, "","",#True,"","","",2000)
      answer$ = PeekS(@answerdo$, -1, #PB_Ascii)    
      pars_res_send = ParseJSON(#PB_Any, answer$)
      If pars_res_send                      
        If getElem(pars_res_send,"ok",0)
          resultanswer=1
          PrintN("<TELEGRAMM> HOOK WAS MADED")
        Else
          PrintN("<TELEGRAMM> Can`t send data to server. Try again after 10s.."+#CRLF$+"BUF["+answer$+"]")
          Delay(10000)
        EndIf
        FreeJSON(pars_res_send)
      Else
        PrintN("<TELEGRAMM> Server: can`t parse data. Try again after 10s.."+#CRLF$+"BUF["+answer$+"]")
        Delay(10000)
      EndIf         
    Until resultanswer
  EndIf
EndProcedure

Procedure runKangaroo(*kangaroo.kangarooStructure)
  Protected  procname$="[SOLVER]",  err$    
  Protected string_win$=LCase("Priv:")
  Protected *Buffer
  Shared settings(), CompilerKangaroo
  Delay(50)
  CompilerKangaroo = RunProgram(settings("1")\programmname ,*kangaroo\params$,"",#PB_Program_Open)  
  If CompilerKangaroo
    PrintN(procname$+"["+settings("1")\programmname+"] programm running..")
    PrintN(procname$+"params ["+*kangaroo\params$+"]")
    While ProgramRunning(CompilerKangaroo)
      err$ = ReadProgramError(CompilerKangaroo)
      If err$
          PrintN (procname$+"Error: "+err$)
      EndIf      
     
      Delay(10)
      
    Wend
      PrintN(procname$+"["+settings("1")\programmname+"] programm finished")
    Else
      PrintN(procname$+"Can't found ["+settings("1")\programmname+"] programm")  
    EndIf    
    CompilerKangaroo=0
  EndProcedure
 
  
Procedure ErrorHandler()
  Protected ErrorMessage$
  
  ErrorMessage$ = "A program error was detected:" + Chr(13) 
  ErrorMessage$ + Chr(13)
  ErrorMessage$ + "Error Message:   " + ErrorMessage()      + Chr(13)
  ErrorMessage$ + "Error Code:      " + Str(ErrorCode())    + Chr(13)  
  ErrorMessage$ + "Code Address:    " + Str(ErrorAddress()) + Chr(13)
 
  If ErrorCode() = #PB_OnError_InvalidMemory   
    ErrorMessage$ + "Target Address:  " + Str(ErrorTargetAddress()) + Chr(13)
  EndIf
 
  If ErrorLine() = -1
    ErrorMessage$ + "Sourcecode line: Enable OnError lines support to get code line information." + Chr(13)
  Else
    ErrorMessage$ + "Sourcecode line: " + Str(ErrorLine()) + Chr(13)
    ErrorMessage$ + "Sourcecode file: " + ErrorFile() + Chr(13)
  EndIf
 
  ErrorMessage$ + Chr(13)
  ErrorMessage$ + "Register content:" + Chr(13)
 
  CompilerSelect #PB_Compiler_Processor 
    CompilerCase #PB_Processor_x86
      ErrorMessage$ + "EAX = " + Str(ErrorRegister(#PB_OnError_EAX)) + Chr(13)
      ErrorMessage$ + "EBX = " + Str(ErrorRegister(#PB_OnError_EBX)) + Chr(13)
      ErrorMessage$ + "ECX = " + Str(ErrorRegister(#PB_OnError_ECX)) + Chr(13)
      ErrorMessage$ + "EDX = " + Str(ErrorRegister(#PB_OnError_EDX)) + Chr(13)
      ErrorMessage$ + "EBP = " + Str(ErrorRegister(#PB_OnError_EBP)) + Chr(13)
      ErrorMessage$ + "ESI = " + Str(ErrorRegister(#PB_OnError_ESI)) + Chr(13)
      ErrorMessage$ + "EDI = " + Str(ErrorRegister(#PB_OnError_EDI)) + Chr(13)
      ErrorMessage$ + "ESP = " + Str(ErrorRegister(#PB_OnError_ESP)) + Chr(13)
 
    CompilerCase #PB_Processor_x64
      ErrorMessage$ + "RAX = " + Str(ErrorRegister(#PB_OnError_RAX)) + Chr(13)
      ErrorMessage$ + "RBX = " + Str(ErrorRegister(#PB_OnError_RBX)) + Chr(13)
      ErrorMessage$ + "RCX = " + Str(ErrorRegister(#PB_OnError_RCX)) + Chr(13)
      ErrorMessage$ + "RDX = " + Str(ErrorRegister(#PB_OnError_RDX)) + Chr(13)
      ErrorMessage$ + "RBP = " + Str(ErrorRegister(#PB_OnError_RBP)) + Chr(13)
      ErrorMessage$ + "RSI = " + Str(ErrorRegister(#PB_OnError_RSI)) + Chr(13)
      ErrorMessage$ + "RDI = " + Str(ErrorRegister(#PB_OnError_RDI)) + Chr(13)
      ErrorMessage$ + "RSP = " + Str(ErrorRegister(#PB_OnError_RSP)) + Chr(13)
      ErrorMessage$ + "Display of registers R8-R15 skipped."         + Chr(13)
 
    CompilerCase #PB_Processor_PowerPC
      ErrorMessage$ + "r0 = " + Str(ErrorRegister(#PB_OnError_r0)) + Chr(13)
      ErrorMessage$ + "r1 = " + Str(ErrorRegister(#PB_OnError_r1)) + Chr(13)
      ErrorMessage$ + "r2 = " + Str(ErrorRegister(#PB_OnError_r2)) + Chr(13)
      ErrorMessage$ + "r3 = " + Str(ErrorRegister(#PB_OnError_r3)) + Chr(13)
      ErrorMessage$ + "r4 = " + Str(ErrorRegister(#PB_OnError_r4)) + Chr(13)
      ErrorMessage$ + "r5 = " + Str(ErrorRegister(#PB_OnError_r5)) + Chr(13)
      ErrorMessage$ + "r6 = " + Str(ErrorRegister(#PB_OnError_r6)) + Chr(13)
      ErrorMessage$ + "r7 = " + Str(ErrorRegister(#PB_OnError_r7)) + Chr(13)
      ErrorMessage$ + "Display of registers r8-R31 skipped."       + Chr(13)
 
  CompilerEndSelect  
  
  
   If  CreateFile(#LOGFILE, FormatDate("%dd_%mm-%hh_%ii_%ss ", Date())+"_error_log.txt",#PB_File_SharedRead )
     WriteStringN(#LOGFILE,FormatDate("%dd/%mm/%hh:%ii:%ss:", Date())+ErrorMessage$,#PB_UTF8)
     FlushFileBuffers(#LOGFILE)
     CloseFile(#LOGFILE)
   EndIf
  ;If StratServ        
 ;       CloseNetworkServer(#Server)
  ;EndIf
End
EndProcedure
;-START
;fractionkangaroo is based on fraction algorithm do the same things as fraction-bsgs but use solver kangaroo from JeanLucPons.
;Requred JeanLucPons kangaroo in the same folder.
;Usage:
;-pos		Set number of pos in division cicle in hex format (ex. -pos FF)
;-dbit		Set number of divisor 2^ (ex. -dbit 6 mean divisor = 2^6 = 64)
;-wl		Set recovery file from which the state will be loaded
;-wt		timer interval for saving work (in seconds)
;-pb		set single uncompressed/compressed pubkey for searching
;-pk		range start from
;-pke		end range
;-maxm		number of operations before give up the search (maxStep*expected operation)
;-dp		number of leading zeros for the DP method
;-t		[kangaroo settings]
;-g		[kangaroo settings]
;-gpuid		[kangaroo settings]
;-gpu		[kangaroo settings]
;Example:
;FractionKangaroo.exe -dp 16 -t 0 -gpu -gpuid 0 -g 88,128 -maxm 2 -dbit 6 -pk 80000000000000000000 -pke ffffffffffffffffffff -pb 037e1238f7b1ce757df94faa9a2eb261bf0aeb9f84dbf81212104e78931c2a19dc 


OnErrorCall(@ErrorHandler())

Define  i, pointcount, ndev, a$, starttime, jobperthread, res, totalCPUcout, restjob, begintime, workingtime, Title$,  result.comparsationStructure, finditems, lastlogtime,totalhash, perf$
Define cnt$, infostr$

PrintN("APP VERSION: "+#appver)

begintime=Date()




*WINKEY=AllocateMemory(32)
If *WINKEY=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf

*WidthRange=AllocateMemory(32)
If *WidthRange=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf

*PrivBIG=AllocateMemory(32)
If *PrivBIG=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
PubkeyBIG\x=AllocateMemory(32)
PubkeyBIG\y=AllocateMemory(32)
If PubkeyBIG\x=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
If PubkeyBIG\y=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
*MaxNonceBIG=AllocateMemory(32)
If *MaxNonceBIG=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
ADDPUBG\x=AllocateMemory(32)
If ADDPUBG\x=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
ADDPUBG\y=AllocateMemory(32)
If ADDPUBG\y=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
*bufferResult=AllocateMemory(32)
If *bufferResult=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
*addX=AllocateMemory(32)
If *addX=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
*addY=AllocateMemory(32)
If *addY=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf

*PRKADDBIG=AllocateMemory(32)
If *PRKADDBIG=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf

PUBADDBIG\x=AllocateMemory(32)
If PUBADDBIG\x=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
PUBADDBIG\y=AllocateMemory(32)
If PUBADDBIG\y=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf


FINDPUBG\x=AllocateMemory(32)
If FINDPUBG\x=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
FINDPUBG\y=AllocateMemory(32)
If FINDPUBG\y=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf

REALPUB\x=AllocateMemory(32)
If REALPUB\x=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
REALPUB\y=AllocateMemory(32)
If REALPUB\y=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf

Two\x=AllocateMemory(32)
If Two\x=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
Two\y=AllocateMemory(32)
If Two\y=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf

FRACTIONBIG\x=AllocateMemory(32)
If FRACTIONBIG\x=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
FRACTIONBIG\y=AllocateMemory(32)
If FRACTIONBIG\y=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf

DIVPUPBIG\x=AllocateMemory(32)
If DIVPUPBIG\x=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
DIVPUPBIG\y=AllocateMemory(32)
If DIVPUPBIG\y=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf

CurrentFRACTION\x=AllocateMemory(32)
If CurrentFRACTION\x=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf
CurrentFRACTION\y=AllocateMemory(32)
If CurrentFRACTION\y=0
  PrintN("Can`t allocate memory")
  exit("")
EndIf

*CurrentFRACTIONNegY=AllocateMemory(32)
*CurElement=AllocateMemory(32)

*OneBig=AllocateMemory(32)

*high=AllocateMemory(104)
*Divisor=AllocateMemory(32)

Curve::m_ADDPTX64(Two\x, Two\y, *CurveGX, *CurveGY, *CurveGX, *CurveGY, *CurveP)


If divisorBit<1 Or divisorBit>192
  exit("Divisor should be at range [1:192]")
EndIf
;----------
If mainpub=""
  ; there no single pubkeys
  exit("At least one pubkey should be set!") 
EndIf

;pubkey
If Len(cuthex(mainpub))<>128
  ;check if it uncompressed
  If Len(cuthex(mainpub))=130 And Left(cuthex(mainpub),2)="04"
    mainpub = Right(cuthex(mainpub), 128)
  Else  
    ;check if it compressed
    If Len(mainpub)=66 And ( Left(mainpub,2)="03" Or Left(mainpub,2)="02")
      mainpub = commpressed2uncomressedPub(mainpub)
    Else
      exit("Invalid Public Key (-pb) length!!!")
    EndIf
  EndIf
EndIf

;generate fingerprint of settings
settingsvalue$ = privkey+privkeyend+mainpub+Str(divisorBit)
settingsFingerPrint$ = SHA1Fingerprint(@settingsvalue$, StringByteLength(settingsvalue$))

;-recovery things
PrintN("Current config hash["+settingsFingerPrint$+"]")
If recovery
  If FileSize(recoveryfilename$) = -1
    exit("Recovery file ["+recoveryfilename$+"] does not exist")    
  EndIf
  If OpenFile(0,recoveryfilename$,#PB_File_NoBuffering)  
    a$=ReadString(0)
    If a$
      recoverypos$ = a$
      a$=ReadString(0)
      If a$
        recoverypub$ = a$
        a$=ReadString(0)
        If a$
          recoveryfraction$=a$
          a$=ReadString(0)
          
            If a$
              recoveryfingerprint$ = a$
              CloseFile(0)
            Else
              CloseFile(0)
              exit("Empty line in recovery file")
            EndIf 
           
                   
        Else
          CloseFile(0)
          exit("Empty line in recovery file")
        EndIf
      Else
        CloseFile(0)
        exit("Empty line in recovery file")
      EndIf
    Else
      CloseFile(0)
      exit("Empty line in recovery file")
    EndIf
    
  Else
     exit("Can`t open recovery file ["+recoveryfilename$+"]")
   EndIf
    PrintN("******Recovery Setttings******")
    PrintN("Position   ["+recoverypos$+"]")
    PrintN("Public key ["+recoverypub$+"]")
    PrintN("Fraction   ["+recoveryfraction$+"]")
    PrintN("CNT        ["+recoveryCNT$+"]")
    PrintN("Config hash["+recoveryfingerprint$+"]")
    PrintN("******************************")
    If recoveryfingerprint$<>settingsFingerPrint$
      exit("Current and recovery configuration are different")
    EndIf
  EndIf



Define wholebitinrange

privkey = RSet(cutHex(privkey),64,"0")

If Len(cuthex(privkey))<>64
  exit("Invalid range (-pk) length!!!")
EndIf

privkeyend = RSet(cutHex(privkeyend),64,"0")
If Len(cuthex(privkey))<>64
  exit("Invalid range (-pkend) length!!!")
EndIf




Curve::m_sethex32(*WidthRange, @privkeyend)

Curve::m_sethex32(*PrivBIG, @privkey)
If Curve::m_check_nonzeroX64(*PrivBIG)=0
  exit("Start range can`t be zero")
EndIf
If Curve::m_check_nonzeroX64(*WidthRange)=1
  If Curve::m_check_less_more_equilX64(*PrivBIG,*WidthRange)<>1
    exit("End range must be more then start range")
  EndIf
EndIf

PrintN("START RANGE= "+Curve::m_gethex32(*PrivBIG))
PrintN("  END RANGE= "+Curve::m_gethex32(*WidthRange))


If Curve::m_check_nonzeroX64(*WidthRange)
  ;endrange is set
  If Curve::m_check_less_more_equilX64(*WidthRange, *PrivBIG)<>2
    ;endrange less or equil beginrange
    exit("End range should be more than begin range!")
  Else    
    
    Curve::m_subModX64(*bufferResult,*WidthRange,*PrivBIG,*Curveqn)    
    
    wholebitinrange=0
    While Curve::m_check_nonzeroX64(*bufferResult)
      Curve::m_shrX64(*bufferResult)
      wholebitinrange+1
    Wend
    
    
    PrintN("WIDTH RANGE= 2^"+Str(wholebitinrange))
    endrangeflag=1
  EndIf
EndIf





finditems=0
globalquit=0
workingtime=Date()
  


a$=RSet(Hex(1), 64,"0")
Curve::m_sethex32(*OneBig, @a$)

;set divisor
a$=RSet(Hex(1), 64,"0") 
Curve::m_sethex32(*Divisor, @a$)
For i = 0 To divisorBit-1
  Curve::m_shlX64(*Divisor)
Next i
PrintN("Divisor 2^"+Str(divisorBit) +"      "+Curve::m_gethex32(*Divisor))






;devide range by divisor
For i = 0 To divisorBit-1  
  Curve::m_shrX64(*PrivBIG);begin range
  Curve::m_shrX64(*WidthRange);end range
Next i

PrintN("DIV START RANGE= "+Curve::m_gethex32(*PrivBIG))
PrintN("DIV   END RANGE= "+Curve::m_gethex32(*WidthRange))

Curve::m_subModX64(*bufferResult,*WidthRange,*PrivBIG,*Curveqn)

wholebitinrange=0
While Curve::m_check_nonzeroX64(*bufferResult)
  Curve::m_shrX64(*bufferResult)
  wholebitinrange+1
Wend
PrintN("WIDTH RANGE= 2^"+Str(wholebitinrange))







Curve::m_subModX64(*WidthRange,*WidthRange,*PrivBIG,*Curveqn)
;PrintN("    START RANGE= 0")
;PrintN("      END RANGE= "+Curve::m_gethex32(*WidthRange))

;-kangaroo settings
If settings("1")\nkang=0
  settings("1")\nkang=44*128*128
EndIf
Define suggestedDP = wholebitinrange / 2.0 - Log(settings("1")\nkang)/Log(2) , pos


settings("1")\getworkrangeBegin="0"
settings("1")\getworkrangeEnd=Curve::m_gethex32(*WidthRange)
If settings("1")\maxm=0
  settings("1")\maxm=2
EndIf
If settings("1")\getworkDP=0  
  PrintN("SuggestedDP:"+Str(suggestedDP))
  settings("1")\getworkDP=suggestedDP
  PrintN("Used suggested DP:"+Str(settings("1")\getworkDP))
EndIf
settings("1")\file$="test1"
settings("1")\programmname="Kangaroo.exe"
settings("1")\jobfilename = "inkangaroo2.txt"

If kangarooparams\params$=""
  kangarooparams\params$ = "-t 0 -gpu -gpuId 0"+" "
EndIf
kangarooparams\params$ + "-d "+Str(settings("1")\getworkDP)+" "
kangarooparams\params$ + "-o "+settings("1")\file$+" "
kangarooparams\params$ + "-m "+StrD(settings("1")\maxm)+" "

kangarooparams\params$ + settings("1")\jobfilename

;delete previous result (priv,pub)
If FileSize(settings("1")\file$)>=0
    DeleteFile(settings("1")\file$)
EndIf

Curve::m_PTMULX64(PubkeyBIG\x, PubkeyBIG\y, *CurveGX, *CurveGY, *PrivBIG,*CurveP)
;make it negative> p-ypoint
Curve::m_subModX64(PubkeyBIG\y,*CurveP,PubkeyBIG\y,*CurveP)
;PrintN("SUBpoint= ("+Curve::m_gethex32(PubkeyBIG\x)+", "+Curve::m_gethex32(PubkeyBIG\y)+")")





a$=Left(cutHex(mainpub),64)
Curve::m_sethex32(FINDPUBG\x, @a$ )
a$=Right(cutHex(mainpub),64)
Curve::m_sethex32(FINDPUBG\y, @a$)
PrintN("")
PrintN("FINDpubkey.c : "+uncomressed2commpressedPub(Curve::m_gethex32(FINDPUBG\x)+Curve::m_gethex32(FINDPUBG\y)))
CopyMemory(FINDPUBG\x,REALPUB\x,32)
CopyMemory(FINDPUBG\y,REALPUB\y,32)  

Curve::m_PTDIVX64(FRACTIONBIG\x, FRACTIONBIG\y, *CurveGX, *CurveGY, *Divisor,*CurveP, *Curveqn)
PrintN("InitFractionX: "+Curve::m_gethex32(FRACTIONBIG\x))
PrintN("InitFractionY: "+Curve::m_gethex32(FRACTIONBIG\y))
PrintN("----------------------------------")

CopyMemory(FRACTIONBIG\x, CurrentFRACTION\x, 32)
CopyMemory(FRACTIONBIG\y, CurrentFRACTION\y, 32)

Curve::m_PTDIVX64(DIVPUPBIG\x, DIVPUPBIG\y, REALPUB\x, REALPUB\y, *Divisor,*CurveP, *Curveqn)

CopyMemory(DIVPUPBIG\x, REALPUB\x, 32)
CopyMemory(DIVPUPBIG\y, REALPUB\y, 32)

;set initial pos
a$=Left(cutHex(curentpos$),64)
Curve::m_sethex32(*CurElement, @a$)

 



If Not recovery
  If curentpos$<>"0"
    If Curve::m_check_less_more_equilX64(*CurElement, *Divisor)=1 
      RecoverFromPos()
    Else
      exit("Position "+curentpos$+" is out of range")
    EndIf
  EndIf 

  If FileSize(#WINFILE)>=0
    DeleteFile(#WINFILE)
  EndIf
Else
  ;recovery  position
  Curve::m_sethex32(*CurElement, @recoverypos$)
  ;recovery  pubkey
  a$=Left(cutHex(commpressed2uncomressedPub(recoverypub$)),64)  
  Curve::m_sethex32(REALPUB\x, @a$ )
  a$=Right(cutHex(commpressed2uncomressedPub(recoverypub$)),64)
  Curve::m_sethex32(REALPUB\y, @a$)  
  ;recovery  currentfraction
  a$=Left(cutHex(commpressed2uncomressedPub(recoveryfraction$)),64)  
  Curve::m_sethex32(CurrentFRACTION\x, @a$ )
  a$=Right(cutHex(commpressed2uncomressedPub(recoveryfraction$)),64)
  Curve::m_sethex32(CurrentFRACTION\y, @a$) 
EndIf


If CreateThread (@saveCurentCNT(),pointcount)
  PrintN("Save work every "+Str(cnttimer)+" seconds")
Else
  exit("Can`t launch thread")
EndIf



quit=0
;--FRACTION

While finditems=0 And Curve::m_check_less_more_equilX64(*CurElement, *Divisor)=1 
  listpos$ = LTrim(Curve::m_gethex32(*CurElement),"0")
  
  
  
  PrintN("Position : "+Curve::m_gethex32(*CurElement))
  PrintN("SearchX  : "+Curve::m_gethex32(REALPUB\x))
  PrintN("SerachY  : "+Curve::m_gethex32(REALPUB\y))
  ;substruct subpoit(initrange) from findpubkey
  Curve::m_ADDPTX64(FINDPUBG\x, FINDPUBG\y, REALPUB\x, REALPUB\y, PubkeyBIG\x, PubkeyBIG\y, *CurveP)
  PrintN("ShiftedX : "+Curve::m_gethex32(FINDPUBG\x))
  PrintN("ShiftedY : "+Curve::m_gethex32(FINDPUBG\y))
  PrintN("FractionX: "+Curve::m_gethex32(CurrentFRACTION\x))
  PrintN("FractionY: "+Curve::m_gethex32(CurrentFRACTION\y))
  ;PrintN("***************************")
  
  
  
  
  Title$="["+#appver+"] "+listpos$+" "+uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y))+"  F:"+Str(finditems)
  ConsoleTitle(Title$)
  
    
  workingtime=Date()
  
  ;---Start kangaroo
  settings("1")\getworkPub="04"+Curve::m_gethex32(FINDPUBG\x)+Curve::m_gethex32(FINDPUBG\y)
  
  If  CreateFile(#JOBFILE, settings("1")\jobfilename ,#PB_File_SharedRead )
    WriteStringN(#JOBFILE,settings("1")\getworkrangeBegin,#PB_UTF8)
    WriteStringN(#JOBFILE,settings("1")\getworkrangeEnd,#PB_UTF8)
    WriteStringN(#JOBFILE,settings("1")\getworkPub,#PB_UTF8)
    FlushFileBuffers(#JOBFILE)
    CloseFile(#JOBFILE)
  Else
    exit("Can`t create input file ["+settings("1")\jobfilename+"]")  
    End
  EndIf

  CreateThread(@runKangaroo(), @kangarooparams)
  
  While Not CompilerKangaroo
    Delay(50)
  Wend
  ;wait while kangarro end
  While CompilerKangaroo
    Delay(50)
  Wend  
  PrintN("Kangaroo finish job")
  If FileSize(settings("1")\file$)<0
    PrintN("File "+settings("1")\file$+" is not exist")
  Else
    If OpenFile(#JOBFILE, settings("1")\file$)
      ;Key# 0 [1S]Pub:  0x03100611C54DFEF604163B8358F7B7FAC13CE478E02CB224AE16D45526B25D9D4D 
       ;Priv: 0xF7051F27B09112D4 
      a$ = ReadString(#JOBFILE , #PB_Ascii)
      PrintN("File->"+a$+"<--")
      If FindString(a$, "Pub:",1,#PB_String_NoCase)            
        fpub$=LCase(cuthex(Right(a$, 69)))
        PrintN("->"+fpub$+"<--")
      Else
         exit("Missing string [Pub:]")   
       EndIf
       a$ = ReadString(#JOBFILE , #PB_Ascii)
       pos=FindString(a$, "Priv: ",1,#PB_String_NoCase) 
       If  pos          
          a$=cutHex(Mid(a$, pos+6))

          PrintN("->"+a$+"<--")
          Curve::m_sethex32(*WINKEY, @a$ )
          Curve::m_addX64(*WINKEY,*WINKEY,*PrivBIG)
          quit=1
        Else
           exit("Missing string [Pub:]")   
         EndIf
        CloseFile(#JOBFILE)
    Else
      exit("Can`t open file ["+settings("1")\file$+"]")  
    EndIf
    
  EndIf
  ;end kangaroo
  If quit
    ;it mean key founded
    PrintN("****************************")
    PrintN( "Solution["+listpos$+"]: 0x"+Curve::m_gethex32(*WINKEY)) 
    Curve::m_mulModX64(*WINKEY,*WINKEY,*Divisor,*Curveqn, *high);res=res * divisor
    Curve::m_addX64(*WINKEY,*WINKEY,*CurElement)                ;res =res+pos
    PrintN("KEY: 0x"+Curve::m_gethex32(*WINKEY))
    Curve::m_PTMULX64(REALPUB\x, REALPUB\y, *CurveGX, *CurveGY, *WINKEY,*CurveP)    
    PrintN( "PUB: "+uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y)))
    PrintN("****************************")
    makehook("Find key for "+uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y)))
    If OpenFile(0, #WINFILE, #PB_File_Append)       
      WriteStringN(0, "KEY: 0x"+Curve::m_gethex32(*WINKEY)) 
      WriteStringN(0, "PUB: "+uncomressed2commpressedPub(Curve::m_gethex32(REALPUB\x)+ Curve::m_gethex32(REALPUB\y)))
      CloseFile(0)                      
    Else
      exit("Can`t create the file!")
    EndIf
    PrintN("Job time "+FormatDate("%hh:%ii:%ss", Date()-workingtime)+"s")  
    finditems+1
  Else
    PrintN("Reached end of space")    
    
    ;--FRACTION
    LockMutex(JobMutex)
    PrintN("----------------------------------")
    ;make it negative> p-ypoint
    Curve::m_subModX64(*CurrentFRACTIONNegY,*CurveP,CurrentFRACTION\y,*CurveP)
    Curve::m_ADDPTX64(REALPUB\x, REALPUB\y, DIVPUPBIG\x, DIVPUPBIG\y, CurrentFRACTION\x, *CurrentFRACTIONNegY, *CurveP)
    
    Curve::m_ADDPTX64(CurrentFRACTION\x, CurrentFRACTION\y, CurrentFRACTION\x, CurrentFRACTION\y, FRACTIONBIG\x, FRACTIONBIG\y, *CurveP)
    
    ;PrintN("-> ("+Curve::m_gethex32(CurrentFRACTION\x)+", "+Curve::m_gethex32(CurrentFRACTION\y)+")")
    
    Curve::m_addX64(*CurElement,*CurElement,*OneBig)
  EndIf

Wend


Title$="["+#appver+"] "+listpos$+" "+Curve::m_gethex32(REALPUB\x)+"  F:"+Str(finditems)
ConsoleTitle(Title$)
globalquit=1   
isreadyjob=0

PrintN("Total time "+FormatDate("%hh:%ii:%ss", Date()-begintime)+"s")   
Delay(2000)
PrintN("cuda finished ok")
exit("")



; IDE Options = PureBasic 5.31 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 1116
; FirstLine = 716
; Folding = 84YkP-0
; EnableThread
; EnableXP
; Executable = FractionKangaroo.exe
; DisableDebugger