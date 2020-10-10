program GOST3411;
{$APPTYPE CONSOLE}
uses
  Windows,   // ����� �������� � ��� ������� �� ����� ��������
  SysUtils,
  dialogs;

var
  n,k,p:integer;                     //���������� ��� ������������� � ������
  nRead: integer;                    //���������� ���������� ���� �� �����
  a:string = 'test1.txt';            //�������� ��� ������������ �����
  fFile: file;                       //����������� ����
  start, stop: TTimeStamp;           //�������� �����
  M: array[0..7] of dword;           //������� 256-������ ����� ���������
  H: array[0..7] of dword;           //��������� ������ �����������
  E: array[0..7] of dword;           //������� �������� ����������� �����
  L: array[0..7] of dword;           //�������� ������������ ����� ��������

  aBuf{,aBuf2}: array[0..31] of byte;  //��������� ����������
  Z: array[0..7] of dword;           //..

{����� �� ����� ��������������� 256 ������� �����}
procedure _writeln(const buf : array of dword; const chr:char);
begin
 writeln(chr+':='
        +inttohex(buf[0],8)+' '+inttohex(buf[1],8)+' '
        +inttohex(buf[2],8)+' '+inttohex(buf[3],8)+#10#13+'   '
        +inttohex(buf[4],8)+' '+inttohex(buf[5],8)+' '
        +inttohex(buf[6],8)+' '+inttohex(buf[7],8));
  writeln('');
end;

{��������������� ����� Byte[32] � ������ DWORD[8]}
procedure convert(const ink:array of byte; var outK:array of dword);
var j,i:integer;
    t:dword;
begin
for j := 0 to 7 do
begin
  t:=ink[j*4];
  for I :=1 to 3 do
  begin
    t:= t shl 8;
    t:= ink[(j*4)+i] xor t;
  end;
  outK[j]:=t;
end;
end;

{��������������� ����� Byte[32] � ������ DWORD[8], �� � �������� �������}
{���������� ��� �������� �����                                          }
procedure LoadConvert(const ink:array of byte; var outK:array of dword);
var j,i,ii:integer;
    t:dword;
begin
ii:=-1;
for j := 7 downto 0 do
begin
  inc(ii);
  t:=ink[j*4+3];
  for I :=2 downto 0 do
  begin
    t:= t shl 8;
    t:= ink[(j*4)+i] xor t;
  end;
  outK[ii]:=t;
end;
end;

{��������������� ����� DWORD[8] � ������ Byte[32]}
procedure unconvert(const ink:array of dword; var outK:array of byte; n:byte);
var j,i:integer;
    t:dword;
begin
for i := 0 to n-1 do
begin
  for j :=3 downto 0 do
  begin
    t:= ink[i] shl (j*8);
    outK[(i*4)+j]:= t shr 24;
  end;
end;
end;

{���� 28147 � ������ ������� ������ }
procedure gost28147(const H,key:array of dword; VAR Res:array of DWORD);
const
tab  :array [0..127] of byte =
 ($1,$F,$D,$0,$5,$7,$A,$4,$9,$2,$3,$E,$6,$B,$8,$C,
  $D,$B,$4,$1,$3,$F,$5,$9,$0,$A,$E,$7,$6,$8,$2,$C,
  $4,$B,$A,$0,$7,$2,$1,$D,$3,$6,$8,$5,$9,$C,$F,$E,
  $6,$C,$7,$1,$5,$F,$D,$8,$4,$A,$9,$E,$0,$3,$B,$2,
  $7,$D,$A,$1,$0,$8,$9,$F,$E,$4,$6,$C,$B,$2,$5,$3,
  $5,$8,$1,$D,$A,$3,$4,$2,$E,$F,$C,$7,$6,$0,$9,$B,
  $E,$B,$4,$C,$6,$D,$F,$A,$2,$3,$8,$1,$0,$7,$5,$9,
  $4,$A,$9,$2,$D,$8,$0,$E,$6,$B,$1,$C,$7,$F,$5,$3 );


var
  H1,H2,T: dword;
  i,j:byte;

begin
  H1:=H[1];  H2:=H[0];                  //�������� N1 � N2
  T:=0;
  for i := 0 to 2 do
  for j := 7 downto 0 do
  begin
     T := (H1+Key[j]) mod 4294967296;
     asm
     pushad
     mov edx,0
     mov eax,t
                      //shl eax, 0
     shr eax,28       //q:= q shr 28;
     lea ebx, tab       //o:=tab[q+112];
                        //add ebx,0
     xlat               //..
                        //q:=T;
                        //q:= q shl (a*4);
                        //q:= q shr 28;
                        //o:=tab[(a*16)+q];
     xor eax, edx         //u:=o xor u;
     shl eax, 4         //u:= u shl 4;
     mov edx,eax
     ///
     mov eax,t
     shl eax, 4
     shr eax,28
     lea ebx, tab
     add ebx,16
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,t
     shl eax, 8
     shr eax,28
     lea ebx, tab
     add ebx,32
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,t
     shl eax, 12
     shr eax,28
     lea ebx, tab
     add ebx,48
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,t
     shl eax, 16
     shr eax,28
     lea ebx, tab
     add ebx,64
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,t
     shl eax, 20
     shr eax,28
     lea ebx, tab
     add ebx,80
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,t
     shl eax, 24
     shr eax,28
     lea ebx, tab
     add ebx,96
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,T        //q:=T;
     shl eax,28       //q:= q shl 28;
     shr eax,28       //q:= q shr 28;
     lea ebx, tab      //o:=tab[q+112];
     add ebx,112       //..
     xlat              //..
     xor eax, edx       //u:=o xor u;
     rol eax, 11      //rol T,11
     xor eax, H2      //T:= T xor  H2;
     mov T,eax
     popad
     end;

     H2:= H1;
     H1:=T;

  end;

for j := 0 to 7 do
  begin
     T := ( H1+Key[j]) mod 4294967296;
     asm
     pushad
     mov edx,0
     mov eax,t
                      //shl eax, 0
     shr eax,28       //q:= q shr 28;
     lea ebx, tab       //o:=tab[q+112];
                        //add ebx,0
     xlat               //..
                        //q:=T;
                        //q:= q shl (a*4);
                        //q:= q shr 28;
                        //o:=tab[(a*16)+q];
     xor eax, edx         //u:=o xor u;
     shl eax, 4         //u:= u shl 4;
     mov edx,eax
     ///
     mov eax,t
     shl eax, 4
     shr eax,28
     lea ebx, tab
     add ebx,16
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,t
     shl eax, 8
     shr eax,28
     lea ebx, tab
     add ebx,32
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,t
     shl eax, 12
     shr eax,28
     lea ebx, tab
     add ebx,48
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,t
     shl eax, 16
     shr eax,28
     lea ebx, tab
     add ebx,64
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,t
     shl eax, 20
     shr eax,28
     lea ebx, tab
     add ebx,80
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,t
     shl eax, 24
     shr eax,28
     lea ebx, tab
     add ebx,96
     xlat
     xor eax, edx
     shl eax, 4
     mov edx,eax
     ///
     mov eax,T        //q:=T;
     shl eax,28       //q:= q shl 28;
     shr eax,28       //q:= q shr 28;
     lea ebx, tab      //o:=tab[q+112];
     add ebx,112       //..
     xlat              //..
     xor eax, edx       //u:=o xor u;
     rol eax, 11      //rol T,11
     xor eax, H2      //T:= T xor  H2;
     mov T,eax
     popad
     end;
      H2:= H1;
      H1:=T;
  end;
  res[0]:=h1;
  res[1]:=h2;
end;

{���� 28147 ��� ������� �������������� �(�)}
procedure concatination (const w: array of DWORD; VAR k: array of DWORD);
begin
  K[6]:=W[4];
  K[7]:=W[5];
  K[2]:=W[0] ;
  K[3]:=W[1] ;
  K[4]:=W[2] ;
  K[5]:=W[3] ;
  K[0]:=W[4] xor W[6];
  K[1]:=W[5] xor W[7];
end;

{���� 28147 ��� ������� �������������� P: V256-->V256}
procedure transform(CONST w : array of byte; var K : array of byte);
var i,j  : integer;
begin
  for i:=0 to 3 do
    for j := 0 to 7 do k[i+4*j]:=w[8*i+j];
end;

{���� 28147 ��� ������� ��������������� �������������� ���: V256-->V256}
procedure shuffle(const A: array of byte; VAR X: array of byte);
var shuff1,shuff2: byte;
    i:integer;
begin

   shuff1:=(A[31] xor A[29] xor A[27] xor A[25] xor A[7] xor A[1]);
   shuff2:=(A[30] xor A[28] xor A[26] xor A[24] xor A[6] xor A[0]);
  X[0]:=shuff2;   X[1]:=shuff1;
  for i:=2 to 31 do
  begin
     X[i]:=A[i-2];
  end;
end;

{�������� ������� - ���������� ������� �������� �������
{������� �� ���� �����
{1. ��������� ������ � ����������� ���������� ���� 28147}
{2. �������������� ��������������                       }
procedure key_gen8(const H, M : array of dword; var RES: array of dword);
CONST
C  :array [0..7] of DWORD =
  ($FF00FFFF,$000000FF,$FF0000FF,$00FFFF00,
   $00FF00FF,$00FF00FF,$FF00FF00,$FF00FF00);
var
    i:INTEGER;
    S,U,V,W,K1,K2,K3,K4 : array [0..7]  of dword;
    b_temp1,b_temp2,b_temp3   : array [0..31] of byte;
    h4,h3,h2,h1       : array [0..1]  of dword;
    S1,S2,S3,S4       : array [0..1]  of DWORD;
begin

 {��������� ������� ������ � �� 4 ������ ��� ���� 28147}
  for I := 0 to 1 do
  BEGIN
    h1[I]:=h[I];
    h2[I]:=h[I+2];
    h3[I]:=h[I+4];
    h4[I]:=h[I+6];
  end;

   {��������� ������ ���� � ����� ��������� ��� � ���� 28147}
   for I := 0 to 7 do W[i]:=H[i] xor M[i];
   unconvert(W,b_temp1,8);
   transform(b_temp1,b_temp2);
   convert(b_temp2,k1);
   gost28147(h4,K1,S1);

   concatination(H,U);
   concatination(M,RES);
   concatination(RES,V);

   {��������� ������ ���� � ��������� ��� � ���� 28147}
   for I := 0 to 7 do W[i]:=U[i] xor V[i];
   unconvert(W,b_temp1,8);
   transform(b_temp1,b_temp2);
   convert(b_temp2,K2);

   gost28147(h3,K2,S2);

   concatination(V,RES);
   concatination(RES,V);
   concatination(U,RES);

   {��������� ������ ���� � ��������� ��� � ���� 28147}
   for I := 0 to 7 do U[i]:=RES[i] xor C[i];
   for I := 0 to 7 do W[i]:=U[i] xor V[i];
   unconvert(W,b_temp1,8);
   transform(b_temp1,b_temp2);
   convert(b_temp2,K3);

   gost28147(h2,K3,S3);

   concatination(V,RES);
   concatination(RES,V);
   concatination(U,RES);

   {��������� ������ ���� � ��������� ��� � ���� 28147}
   for I := 0 to 7 do W[i]:=RES[i] xor V[i];

   unconvert(W,b_temp1,8);
   transform(b_temp1,b_temp2);
   convert(b_temp2,K4);

   gost28147(h1,K4,S4);

  {�������� ���������� ����'�� 28147 � ������ ������ S}
   for I := 0 to 1 do
   BEGIN
    S[I]:=S4[I];
    S[I+2]:=S3[I];
    S[I+4]:=S2[I];
    S[I+6]:=S1[I];
   end;

   {���������� �������������� ��������������}
    unconvert(S,b_temp1,8);            //DWORD[8] ������������ � BYTE[32]
    
    for i:=1 to 6 do
    begin
       shuffle(b_temp1,b_temp2);       //���� �������������� �������
       shuffle(b_temp2,b_temp1);       //...
    end;

    unconvert(M,b_temp3,8);
    for I := 0 to 31 do b_temp1[i]:=b_temp1[i] xor b_temp3[i];

    shuffle(b_temp1,b_temp2);

    unconvert(H,b_temp3,8);
    for I := 0 to 31 do b_temp1[i]:=b_temp2[i] xor b_temp3[i];

    for i:=1 to 30 do
    begin
       shuffle(b_temp1,b_temp2);
       shuffle(b_temp2,b_temp1);
    end;

    shuffle(b_temp1,b_temp2);
    convert(b_temp2,RES);
end;

{�������� ������� � ������ �[8]:=A[8]+b �� ������ 256  }
procedure addblock(const a :array of dword;const  b: word; var c:array of dword);
var sum: int64;
    carr: dword;
    i:byte;
begin
  sum:=a[7]+b;
  carr:= sum shr 32;
  c[7]:=sum;
  for i := 6 downto 0 do
  begin
    sum:=a[i]+carr;
    carr:= sum shr 32;
    c[i]:=sum;
  end;
end;

{�������� �������� �[8]:=A[8]+b[8] �� ������ 256  }
procedure summblock(const a,b :array of dword; var c:array of dword);
var sum: int64;
    carr: dword;
    i:byte;
begin
  carr:=0;
  for I := 7 downto 0 do
  begin
    sum:=a[i]+b[i]+carr;
    carr:= sum shr 32;
    c[i]:=sum;
  end;

end;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                               ���� ���������                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

begin
////////�������.......
// � ���� 28147
// ��� ���������� ����� ����� � ������ ������������������
// � ����� �[1..2] � ��������....
//.......................................................

  { ����������� ��������� �������� }
  L[0]:=$0;  L[1]:=$0;
  L[2]:=$0;  L[3]:=$0;
  L[4]:=$0;  L[5]:=$0;
  L[6]:=$0;  L[7]:=$0;

  E[0]:=$0;  E[1]:=$0;
  E[2]:=$0;  E[3]:=$0;
  E[4]:=$0;  E[5]:=$0;
  E[6]:=$0;  E[7]:=$0;

  H[0]:=$0;  H[1]:=$0;
  H[2]:=$0;  H[3]:=$0;
  H[4]:=$0;  H[5]:=$0;
  H[6]:=$0;  H[7]:=$0;

  { ������� ��������� ������� �������� t1-������ ������   }
  { ������� ��������� ������� �������� t2-������ ������   }
  { ������� ��������� ������� �������� t0-� ������� ����� }

  if (ParamStr(1)='/t1')
  then a:='test1.txt'
  else if (ParamStr(1)='/t2')
       then a:='test2.txt'
       else
         with Topendialog.Create(nil) do
         begin
         Options := [ofFileMustExist, ofHideReadOnly];
         Title := 'Select a file';
           execute;
           a:=filename;
         end; // ���� ���� ����������� �������
              // ����� ����� ������.


////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                   �������� ���������� �������� ����                        //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

     {��������� ���� �� ������}
     writeln(a);
     writeln('');
     Assign(fFile, a);
     Reset(fFile, 1);

     {���������� ���������� ������}
     k:=filesize(fFile) div 32;
     if (filesize(fFile) mod 32)=0  then k:=k-1;

     {�������� �����}
     start := DateTimeToTimeStamp(Now);

     {�������� ���� ����������� �������� � ���}
     for p := 1 to k do
     begin                                  //����� ����� � �����
       BlockRead(fFile, aBuf, SizeOf(aBuf),nread);
       //convert(aBuf,M,8);                  //BYTE[32] ��������� � DWORD[8]
       LoadConvert(aBuf,M);
       key_gen8(H, M, Z);                   //������� �������
       for n := 0 to 7 do  H[n]:=Z[n];
       addblock(L,256,L);                   // �������� �������� �� mod 2
       summblock(M,E,E);                    // �������� E=<M+E> mod K=|M|=|E|
     end;

     { ������ ����������� ������� ����� }
     //for n := 0 to 31 do aBuf[n]:=0;
     BlockRead(fFile, aBuf, SizeOf(aBuf),nread);//����� ����� � �����

     { ������� ����� �� 256 ������� ����� }
     for n := nread to 31 do aBuf[n]:=0;

     {���� ������������������ ����������}
     LoadConvert(aBuf,M);                 //BYTE[32] ��������� � DWORD[8]

     addblock(L,nread*8,L);               // �������� �������� �� mod 2
     summblock(E,M, E);                   // �������� E=<M+E> mod K=|M|=|E|
     key_gen8(H,M,Z);
     key_gen8(Z, L, H);
     key_gen8(H, E, Z);

     {����� �� ����� ����������}
     _writeln(Z,'H');
     stop := DateTimeToTimeStamp(Now);
     writeln('Speed := '+inttostr(filesize(fFile))+'byte/'+inttostr(stop.Time-start.Time)+' ms');

     CloseFile(fFile);

  // ��� ����� ���������� ���� ��������������� ��� ������� ENTER
  READLN;
end.
