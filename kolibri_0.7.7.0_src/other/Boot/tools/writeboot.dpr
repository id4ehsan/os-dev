{$APPTYPE CONSOLE}
var
  f1,f2:file of byte;
  i:integer;
  b:byte;
begin
  assign(f1,'menuet.img');
  reset(f1);
  if ioresult<>0 then
  begin
    writeln('can''t find menuet.img');
    exit;
  end;
  assign(f2,'bootmosf.bin');
  reset(f2);
  if ioresult<>0 then
  begin
    writeln('can''t find bootmosf.bin');
    exit;
  end;
  for i:=1 to 512 do
  begin
    read(f2,b);
    write(f1,b);
  end;
end.