unit collision;

{$mode ObjFPC}{$H+}

interface

uses
  Raylib, RayMath, Classes, SysUtils;

procedure PointNearestRectanglePoint(rect: TRectangle; point: TVector2;  nearest, normal: PVector2);
function IntersectBBoxSphere(bounds: TBoundingBox; center: PVector3; initalPosition: TVector3; radius, height: Single; intersectionPoint, hitNormal: PVector3): Boolean;

implementation

procedure PointNearestRectanglePoint(rect: TRectangle; point: TVector2;
  nearest, normal: PVector2);
var hValue, hNormal, dotForPoint: Single;
    vecToPoint, nearestPoint: TVector2;
begin
  // get the closest point on the vertical sides
  hValue := rect.x;
  hNormal := -1;
  if (point.x > rect.x + rect.width) then
  begin
      hValue := rect.x + rect.width;
      hNormal := 1;
  end;

  vecToPoint := Vector2Subtract(Vector2Create (hValue, rect.y)), point);
  // get the dot product between the ray and the vector to the point
  float dotForPoint = Vector2DotProduct(Vector2{ 0, -1 }, vecToPoint);
  Vector2 nearestPoint = { hValue, 0 };

  if (dotForPoint < 0)
      nearestPoint.y = rect.y;
  else if (dotForPoint >= rect.height)
      nearestPoint.y = rect.y + rect.height;
  else
      nearestPoint.y = rect.y + dotForPoint;

  // get the closest point on the horizontal sides
  float vValue = rect.y;
  float vNormal = -1;
  if (point.y > rect.y + rect.height)
  begin
      vValue = rect.y + rect.height;
      vNormal = 1;
  end;

  vecToPoint = Vector2Subtract(Vector2{ rect.x, vValue }, point);
  // get the dot product between the ray and the vector to the point
  dotForPoint = Vector2DotProduct(Vector2{ -1, 0 }, vecToPoint);
  nearest = Vector2{ 0,vValue };

  if (dotForPoint < 0)
      nearest.x = rect.x;
  else if (dotForPoint >= rect.width)
      nearest.x = rect.x + rect.width;
  else
      nearest.x = rect.x + dotForPoint;

  if (Vector2LengthSqr(Vector2Subtract(point, nearestPoint)) <= Vector2LengthSqr(Vector2Subtract(point, nearest)))
  begin
      nearest = nearestPoint;
      normal.x = hNormal;
      normal.y = 0;
  end
  else
  begin
      normal.y = vNormal;
      normal.x = 0;
  end;
end;

function IntersectBBoxSphere(bounds: TBoundingBox; center: PVector3;
  initalPosition: TVector3; radius, height: Single; intersectionPoint,
  hitNormal: PVector3): Boolean;
begin

end;

end.

