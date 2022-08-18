unit MathUtils;

{$mode ObjFPC}{$H+}

interface

uses
  raylib, raymath;

  function SmoothDamp(from, to_: Single   ; speed, dt: Single): Single;
  function SmoothDamp(from, to_: TVector3 ; speed, dt: Single): TVector3;
  function SmoothDamp(from, to_: TQuaternion; speed, dt: Single): TQuaternion;

implementation

function SmoothDamp(from, to_: Single; speed, dt: Single): Single;
begin
  result:= Lerp(from, to_, 1 - exp(-speed * dt));
end;

function SmoothDamp(from, to_: TVector3; speed, dt: Single): TVector3;
begin
  result:= Vector3Create(Lerp(from.x, to_.x, 1 - exp(-speed * dt)),
                         Lerp(from.y, to_.y, 1 - exp(-speed * dt)),
		         Lerp(from.z, to_.z, 1 - exp(-speed * dt)));
end;

function SmoothDamp(from, to_: TQuaternion; speed, dt: Single): TQuaternion;
begin
  result:= QuaternionSlerp( from, to_, 1 - exp(-speed * dt));
end;

end.

