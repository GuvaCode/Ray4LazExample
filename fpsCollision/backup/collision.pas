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
var hValue, hNormal, dotForPoint, vValue, vNormal: Single;
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

  vecToPoint := Vector2Subtract(Vector2Create(hValue, rect.y), point);

  // get the dot product between the ray and the vector to the point
 dotForPoint := Vector2DotProduct(Vector2Create( 0, -1 ), vecToPoint);
 nearestPoint := Vector2Create( hValue, 0 );

  if (dotForPoint < 0) then nearestPoint.y := rect.y
  else
    if (dotForPoint >= rect.height) then nearestPoint.y := rect.y + rect.height
  else
      nearestPoint.y := rect.y + dotForPoint;

  // get the closest point on the horizontal sides
  vValue := rect.y;
  vNormal := -1;
  if (point.y > rect.y + rect.height) then
  begin
      vValue := rect.y + rect.height;
      vNormal := 1;
  end;

  vecToPoint := Vector2Subtract(Vector2Create( rect.x, vValue ), point);
  // get the dot product between the ray and the vector to the point
  dotForPoint := Vector2DotProduct(Vector2Create( -1, 0 ), vecToPoint);
  nearest^ := Vector2Create( 0,vValue );

  if (dotForPoint < 0) then nearest^.x := rect.x
  else if (dotForPoint >= rect.width) then
      nearest^.x := rect.x + rect.width
  else
      nearest^.x := rect.x + dotForPoint;

  if Vector2LengthSqr(Vector2Subtract(point, nearestPoint)) <= Vector2LengthSqr(Vector2Subtract(point, nearest^)) then
  begin
      nearest^ := nearestPoint;
      normal^.x := hNormal;
      normal^.y := 0;
  end
  else
  begin
      normal^.y := vNormal;
      normal^.x := 0;
  end;
end;

function IntersectBBoxSphere(bounds: TBoundingBox; center: PVector3;
  initalPosition: TVector3; radius, height: Single; intersectionPoint,
  hitNormal: PVector3): Boolean;
const MinFloat: Single = 1.17549435E-38; // Минимальное нормализованное положительное

var rect: TRectangle;
    center2d, newPosOrigin, hitPoint, hitNormal2d, vectorToHit, projectedPoint, delta : TVector2;
    movementVec: TVector3;
    yParam, centerTop, oldTop: Single;

begin
  rect := RectangleCreate( bounds.min.x, bounds.min.z, bounds.max.x - bounds.min.x, bounds.max.z - bounds.min.z );
  center2d := Vector2Create(center^.x, center^.z );

  if (not CheckCollisionCircleRec(center2d, radius, rect)) then
      result := false;

  // we are above or below
  if (center^.y > bounds.max.y) then
      result := false;

  if (center^.y + height < bounds.min.y) then
      result := false;

  // see if we landed on top
  if (center^.y <= bounds.max.y) and (initalPosition.y > bounds.max.y) and (initalPosition.y > center^.y) then
  begin
    // we have hit the top of the obstacle, so clamp our position to where we hit that Y
    movementVec := Vector3Subtract(center^, initalPosition);
    yParam := (initalPosition.y - bounds.max.y) / movementVec.y;
    movementVec := Vector3Scale(movementVec, yParam);
    center^ := Vector3Add(initalPosition, movementVec);
    intersectionPoint := @center;
    hitNormal^ := Vector3Create( 0,1,0 );
    result :=  true;
  end;

  // see if we hit the bottom
  centerTop := center^.y + height;
  oldTop := initalPosition.y + height;

  if (centerTop >= bounds.min.y) and (oldTop < bounds.min.y) and (initalPosition.y < center^.y) then
  begin
    // simple situation of
    center := @initalPosition;
    intersectionPoint := @center;
    hitNormal^ := Vector3Create( 0,-1,0 );
    result := true;
  end;

  newPosOrigin := Vector2Create( center^.x, center^.z );
  hitPoint := Vector2Create(MinFloat, MinFloat);
  hitNormal2d := Vector2Create(0,0);

  PointNearestRectanglePoint(rect, newPosOrigin, @hitPoint, @hitNormal2d);

  vectorToHit := Vector2Subtract(hitPoint, newPosOrigin);

  if (Vector2LengthSqr(vectorToHit) >= radius * radius) then
     result := false;

  intersectionPoint^ := Vector3Create( hitPoint.x, center^.y, hitPoint.y );
  hitNormal^ := Vector3Create( hitNormal2d.x, 0, hitNormal2d.y );

  // normalize the vector along the point to where we are nearest
  vectorToHit := Vector2Normalize(vectorToHit);

  // project that out to the radius to find the point that should be 'deepest' into the rectangle.
  projectedPoint := Vector2Add(newPosOrigin, Vector2Scale(vectorToHit, radius));

  // compute the shift to take the deepest point out to the edge of our nearest hit, based on the vector direction
  delta := Vector2Create( 0,0 );

  if (hitNormal^.x <> 0) then
   delta.x := hitPoint.x - projectedPoint.x
    else
   delta.y := hitPoint.y - projectedPoint.y;

  // shift the new point by the delta to push us outside of the rectangle
  newPosOrigin := Vector2Add(newPosOrigin, delta);

  center := Vector3Create( newPosOrigin.x, center^.y, newPosOrigin.y );
  result := true;
end;

end.

