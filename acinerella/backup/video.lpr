program video;

{$mode Delphi}{$H+}

uses cmem,
ray_header,acinerella, Classes, SysUtils;

const
 screenWidth = 800;
 screenHeight = 600;

var
  inst: PAc_instance;
  pack: PAc_package;
  info: TAc_stream_info;
  videodecoder: PAc_decoder;
  i, w, h: integer;
  psrc: PByte;
  img: TImage;
  texture: ttexture2d;
  fs: TFileStream;
  read_cnt: integer;

  function read_proc(sender: Pointer; buf: PChar; size: integer): integer; cdecl;
  begin
    inc(read_cnt);
    result := fs.Read(buf^, size);
  end;

begin
 InitWindow(screenWidth, screenHeight, 'raylib pascal - basic window');
 videodecoder := nil;
  fs := TFileStream.Create('data/orion.mpg', fmOpenRead);
  fs.Position := 0;
  inst := ac_init();
  {$IFDEF FPC}
  inst^.output_format := AC_OUTPUT_RGB24;
  {$ENDIF}

  ac_open(inst, nil,nil, @read_proc, nil, nil, nil);

  Writeln('Count of Datastreams: ', inst^.stream_count);
  Writeln('Length of the file: ', inst^.info.duration);
  Writeln('Title: ', PChar(@(inst^.info.title[0])));
  Writeln('Author: ', PChar(@(inst^.info.author[0])));
  Writeln('Album: ', PChar(@(inst^.info.album[0])));
  Writeln('Genre: ', PChar(@(inst^.info.genre[0])));


  for i := 0 to inst^.stream_count - 1 do
  begin
    Writeln;
    ac_get_stream_info(inst, i, @info);
    Writeln('Information about stream ', i, ':');

    case info.stream_type of
    AC_STREAM_TYPE_VIDEO:
      begin
        Writeln('Stream is an video stream.');
        Writeln('--------------------------');
        Writeln;
        Writeln(' * Width             : ', info.additional_info.video_info.frame_width, 'px');
        Writeln(' * Height            : ', info.additional_info.video_info.frame_height, 'px');
        Writeln(' * Pixel aspect      : ', FormatFloat('#.##', info.additional_info.video_info.pixel_aspect));
        Writeln(' * Frames per second : ', FormatFloat('#.##', info.additional_info.video_info.frames_per_second));

        if videodecoder = nil then
        begin
          videodecoder := ac_create_decoder(inst, i);
          h := videodecoder^.stream_info.additional_info.video_info.frame_height;
          w := videodecoder^.stream_info.additional_info.video_info.frame_width;
          img.width:=w;
          img.height:=h;
          img.mipmaps:=1;
          img.format := PIXELFORMAT_UNCOMPRESSED_R8G8B8;
        end;
      end;
     end;
   end;




  if not inst^.opened then
   begin
    Writeln('No video/audio information found. Press return to leave.');
    Readln;
    exit;
   end;

while not WindowShouldClose() do
begin
     pack := ac_read_package(inst);
      if pack <> nil then
      if (videodecoder <> nil) and (videodecoder^.stream_index = pack^.stream_index) then
      if (ac_decode_package(pack, videodecoder) > 0) then
       begin
        psrc := videodecoder^.buffer;
        img.data:=psrc;
        texture := LoadTextureFromImage(img);
       end;

  BeginDrawing();
  ClearBackground(BLACK);
  DrawTexture(texture, GetScreenWidth div 2 - texture.width div 2, GetScreenHeight div 2 - texture.height div 2, WHITE);
  EndDrawing();
   end;

CloseWindow(); 

end.

