/// Original version from ProBuilder 4.0.
/// Certains methods have been stripped out due to dependencies.

using System;
using System.Collections.Generic;

namespace UnityEngine.Polybrush
{
    /// <summary>
    /// A collection of math functions that are useful when working with 3d meshes.
    /// </summary>
    public static class Math
    {
        /// <summary>
        /// Pi / 2.
        /// </summary>
        public const float phi = 1.618033988749895f;

        /// <summary>
        /// ProBuilder epsilon constant.
        /// </summary>
        const float k_FltEpsilon = float.Epsilon;

        /// <summary>
        /// Epsilon to use when comparing vertex positions for equality.
        /// </summary>
        const float k_FltCompareEpsilon = .0001f;

        /// <summary>
        /// The minimum distance a handle must move on an axis before considering that axis as engaged.
        /// </summary>
        internal const float handleEpsilon = .0001f;

        /// <summary>
        /// Get a point on the circumference of a circle.
        /// </summary>
        /// <param name="radius">The radius of the circle.</param>
        /// <param name="angleInDegrees">Where along the circle should the point be projected. Angle is in degrees.</param>
        /// <param name="origin"></param>
        /// <returns></returns>
        internal static Vector2 PointInCircumference(float radius, float angleInDegrees, Vector2 origin)
        {
            // Convert from degrees to radians via multiplication by PI/180
            float x = (float)(radius * Mathf.Cos(Mathf.Deg2Rad * angleInDegrees)) + origin.x;
            float y = (float)(radius * Mathf.Sin(Mathf.Deg2Rad * angleInDegrees)) + origin.y;

            return new Vector2(x, y);
        }

        /// <summary>
        /// Provided a radius, latitudinal and longitudinal angle, return a position.
        /// </summary>
        /// <param name="radius"></param>
        /// <param name="latitudeAngle"></param>
        /// <param name="longitudeAngle"></param>
        /// <returns></returns>
        internal static Vector3 PointInSphere(float radius, float latitudeAngle, float longitudeAngle)
        {
            float x = (radius * Mathf.Cos(Mathf.Deg2Rad * latitudeAngle) * Mathf.Sin(Mathf.Deg2Rad * longitudeAngle));
            float y = (radius * Mathf.Sin(Mathf.Deg2Rad * latitudeAngle) * Mathf.Sin(Mathf.Deg2Rad * longitudeAngle));
            float z = (radius * Mathf.Cos(Mathf.Deg2Rad * longitudeAngle));

            return new Vector3(x, y, z);
        }

        /// <summary>
        /// Find the signed angle from direction a to direction b.
        /// </summary>
        /// <param name="a">The direction from which to rotate.</param>
        /// <param name="b">The direction to rotate towards.</param>
        /// <returns>A signed angle in degrees from direction a to direction b.</returns>
        internal static float SignedAngle(Vector2 a, Vector2 b)
        {
            float t = Vector2.Angle(a, b);
            if (b.x - a.x < 0)
                t = 360f - t;
            return t;
        }

        /// <summary>
        /// Squared distance between two points. This is the same as `(b - a).sqrMagnitude`.
        /// </summary>
        /// <param name="a">First point.</param>
        /// <param name="b">Second point.</param>
        /// <returns></returns>
        public static float SqrDistance(Vector3 a, Vector3 b)
        {
            float dx = b.x - a.x,
                  dy = b.y - a.y,
                  dz = b.z - a.z;
            return dx * dx + dy * dy + dz * dz;
        }

        /// <summary>
        /// Get the area of a triangle.
        /// </summary>
        /// <remarks>http://www.iquilezles.org/blog/?p=1579</remarks>
        /// <param name="x">First vertex position of the triangle.</param>
        /// <param name="y">Second vertex position of the triangle.</param>
        /// <param name="z">Third vertex position of the triangle.</param>
        /// <returns>The area of the triangle.</returns>
        public static float TriangleArea(Vector3 x, Vector3 y, Vector3 z)
        {
            float   a = SqrDistance(x, y),
                    b = SqrDistance(y, z),
                    c = SqrDistance(z, x);

            return Mathf.Sqrt((2f * a * b + 2f * b * c + 2f * c * a - a * a - b * b - c * c) / 16f);
        }

        /// <summary>
        /// Returns the Area of a polygon.
        /// </summary>
        /// <param name="vertices"></param>
        /// <param name="indexes"></param>
        /// <returns></returns>
        internal static float PolygonArea(Vector3[] vertices, int[] indexes)
        {
            float area = 0f;

            for (int i = 0; i < indexes.Length; i += 3)
                area += TriangleArea(vertices[indexes[i]], vertices[indexes[i + 1]], vertices[indexes[i + 2]]);

            return area;
        }

        /// <summary>
        /// Returns a new point by rotating the Vector2 around an origin point.
        /// </summary>
        /// <param name="v">Vector2 original point.</param>
        /// <param name="origin">The pivot to rotate around.</param>
        /// <param name="theta">How far to rotate in degrees.</param>
        /// <returns></returns>
        internal static Vector2 RotateAroundPoint(this Vector2 v, Vector2 origin, float theta)
        {
            float cx = origin.x, cy = origin.y; // origin
            float px = v.x, py = v.y;           // point

            float s = Mathf.Sin(theta * Mathf.Deg2Rad);
            float c = Mathf.Cos(theta * Mathf.Deg2Rad);

            // translate point back to origin:
            px -= cx;
            py -= cy;

            // rotate point
            float xnew = px * c + py * s;
            float ynew = -px * s + py * c;

            // translate point back:
            px = xnew + cx;
            py = ynew + cy;

            return new Vector2(px, py);
        }

        /// <summary>
        /// Scales a Vector2 using origin as the pivot point.
        /// </summary>
        /// <param name="v"></param>
        /// <param name="origin"></param>
        /// <param name="scale"></param>
        /// <returns></returns>
        public static Vector2 ScaleAroundPoint(this Vector2 v, Vector2 origin, Vector2 scale)
        {
            Vector2 tp = v - origin;
            tp = Vector2.Scale(tp, scale);
            tp += origin;

            return tp;
        }

        /// <summary>
        /// Reflects a point across a line segment.
        /// </summary>
        /// <param name="point">The point to reflect.</param>
        /// <param name="lineStart">First point of the line segment.</param>
        /// <param name="lineEnd">Second point of the line segment.</param>
        /// <returns>The reflected point.</returns>
        public static Vector2 ReflectPoint(Vector2 point, Vector2 lineStart, Vector2 lineEnd)
        {
            Vector2 line = lineEnd - lineStart;
            Vector2 perp = new Vector2(-line.y, line.x);    // skip normalize

            float dist = Mathf.Sin(Vector2.Angle(line, point - lineStart) * Mathf.Deg2Rad) * Vector2.Distance(point, lineStart);

            return point + perp * (dist * 2f) * (Vector2.Dot(point - lineStart, perp) > 0 ? -1f : 1f);
        }

        internal static float SqrDistanceRayPoint(Ray ray, Vector3 point)
        {
            return Vector3.Cross(ray.direction, point - ray.origin).sqrMagnitude;
        }

        /// <summary>
        /// Get the distance between a point and a finite line segment.
        /// </summary>
        /// <remarks>http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment</remarks>
        /// <param name="point">The point.</param>
        /// <param name="lineStart">Line start.</param>
        /// <param name="lineEnd">Line end.</param>
        /// <returns>The distance from point to the nearest point on a line segment.</returns>
        public static float DistancePointLineSegment(Vector2 point, Vector2 lineStart, Vector2 lineEnd)
        {
            // Return minimum distance between line segment vw and point p
            float l2 = ((lineStart.x - lineEnd.x) * (lineStart.x - lineEnd.x)) + ((lineStart.y - lineEnd.y) * (lineStart.y - lineEnd.y));  // i.e. |w-v|^2 -  avoid a sqrt

            if (l2 == 0.0f) return Vector2.Distance(point, lineStart);   // v == w case

            // Consider the line extending the segment, parameterized as v + t (w - v).
            // We find projection of point p onto the line.
            // It falls where t = [(p-v) . (w-v)] / |w-v|^2
            float t = Vector2.Dot(point - lineStart, lineEnd - lineStart) / l2;

            if (t < 0.0)
                return Vector2.Distance(point, lineStart);              // Beyond the 'v' end of the segment
            else if (t > 1.0)
                return Vector2.Distance(point, lineEnd);            // Beyond the 'w' end of the segment

            Vector2 projection = lineStart + t * (lineEnd - lineStart);     // Projection falls on the segment

            return Vector2.Distance(point, projection);
        }

        /// <summary>
        /// Get the distance between a point and a finite line segment.
        /// </summary>
        /// <remarks>http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment</remarks>
        /// <param name="point">The point.</param>
        /// <param name="lineStart">Line start.</param>
        /// <param name="lineEnd">Line end.</param>
        /// <returns>The distance from point to the nearest point on a line segment.</returns>
        public static float DistancePointLineSegment(Vector3 point, Vector3 lineStart, Vector3 lineEnd)
        {
            // Return minimum distance between line segment vw and point p
            float l2 = ((lineStart.x - lineEnd.x) * (lineStart.x - lineEnd.x)) + ((lineStart.y - lineEnd.y) * (lineStart.y - lineEnd.y)) + ((lineStart.z - lineEnd.z) * (lineStart.z - lineEnd.z));  // i.e. |w-v|^2 -  avoid a sqrt

            if (l2 == 0.0f) return Vector3.Distance(point, lineStart);   // v == w case

            // Consider the line extending the segment, parameterized as v + t (w - v).
            // We find projection of point p onto the line.
            // It falls where t = [(p-v) . (w-v)] / |w-v|^2
            float t = Vector3.Dot(point - lineStart, lineEnd - lineStart) / l2;

            if (t < 0.0)
                return Vector3.Distance(point, lineStart);              // Beyond the 'v' end of the segment
            else if (t > 1.0)
                return Vector3.Distance(point, lineEnd);            // Beyond the 'w' end of the segment

            Vector3 projection = lineStart + t * (lineEnd - lineStart);     // Projection falls on the segment

            return Vector3.Distance(point, projection);
        }

        /// <summary>
        /// Calculate the nearest point between two rays.
        /// </summary>
        /// <param name="a">First ray.</param>
        /// <param name="b">Second ray.</param>
        /// <returns></returns>
        public static Vector3 GetNearestPointRayRay(Ray a, Ray b)
        {
            return GetNearestPointRayRay(a.origin, a.direction, b.origin, b.direction);
        }

        internal static Vector3 GetNearestPointRayRay(Vector3 ao, Vector3 ad, Vector3 bo, Vector3 bd)
        {
            float dot = Vector3.Dot(ad, bd);
            float abs = Mathf.Abs(dot);

            // ray is parallel (or garbage)
            if ((abs - 1f) > Mathf.Epsilon || abs < Mathf.Epsilon)
                return ao;

            Vector3 c = bo - ao;

            float n = -dot * Vector3.Dot(bd, c) + Vector3.Dot(ad, c) * Vector3.Dot(bd, bd);
            float d = Vector3.Dot(ad, ad) * Vector3.Dot(bd, bd) - dot * dot;

            return ao + ad * (n / d);
        }

        // http://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect
        // Returns 1 if the lines intersect, otherwise 0. In addition, if the lines
        // intersect the intersection point may be stored in the intersect var
        internal static bool GetLineSegmentIntersect(Vector2 p0, Vector2 p1, Vector2 p2, Vector2 p3, ref Vector2 intersect)
        {
            intersect = Vector2.zero;
            Vector2 s1, s2;
            s1.x = p1.x - p0.x;     s1.y = p1.y - p0.y;
            s2.x = p3.x - p2.x;     s2.y = p3.y - p2.y;

            float s, t;
            s = (-s1.y * (p0.x - p2.x) + s1.x * (p0.y - p2.y)) / (-s2.x * s1.y + s1.x * s2.y);
            t = (s2.x * (p0.y - p2.y) - s2.y * (p0.x - p2.x)) / (-s2.x * s1.y + s1.x * s2.y);

            if (s >= 0 && s <= 1 && t >= 0 && t <= 1)
            {
                // Collision detected
                intersect.x = p0.x + (t * s1.x);
                intersect.y = p0.y + (t * s1.y);
                return true;
            }

            return false;
        }

        /// <summary>
        /// True or false lines, do lines intersect.
        /// </summary>
        /// <param name="p0"></param>
        /// <param name="p1"></param>
        /// <param name="p2"></param>
        /// <param name="p3"></param>
        /// <returns></returns>
        internal static bool GetLineSegmentIntersect(Vector2 p0, Vector2 p1, Vector2 p2, Vector2 p3)
        {
            Vector2 s1, s2;
            s1.x = p1.x - p0.x;     s1.y = p1.y - p0.y;
            s2.x = p3.x - p2.x;     s2.y = p3.y - p2.y;

            float s, t;
            s = (-s1.y * (p0.x - p2.x) + s1.x * (p0.y - p2.y)) / (-s2.x * s1.y + s1.x * s2.y);
            t = (s2.x * (p0.y - p2.y) - s2.y * (p0.x - p2.x)) / (-s2.x * s1.y + s1.x * s2.y);

            return (s >= 0 && s <= 1 && t >= 0 && t <= 1);
        }

        /// <summary>
        /// Test if a raycast intersects a triangle. Does not test for culling.
        /// </summary>
        /// <remarks>
        /// http://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm
        /// http://www.cs.virginia.edu/~gfx/Courses/2003/ImageSynthesis/papers/Acceleration/Fast%20MinimumStorage%20RayTriangle%20Intersection.pdf
        /// </remarks>
        /// <param name="InRay"></param>
        /// <param name="InTriangleA">First vertex position in the triangle.</param>
        /// <param name="InTriangleB">Second vertex position in the triangle.</param>
        /// <param name="InTriangleC">Third vertex position in the triangle.</param>
        /// <param name="OutDistance">If triangle is intersected, this is the distance of intersection point from ray origin. Zero if not intersected.</param>
        /// <param name="OutPoint">If triangle is intersected, this is the point of collision. Zero if not intersected.</param>
        /// <returns>True if ray intersects, false if not.</returns>
        public static bool RayIntersectsTriangle(Ray InRay, Vector3 InTriangleA, Vector3 InTriangleB, Vector3 InTriangleC,
            out float OutDistance, out Vector3 OutPoint)
        {
            OutDistance = 0f;
            OutPoint = Vector3.zero;

            //Find vectors for two edges sharing V1
            Vector3 e1 = InTriangleB - InTriangleA;
            Vector3 e2 = InTriangleC - InTriangleA;

            //Begin calculating determinant - also used to calculate `u` parameter
            Vector3 P = Vector3.Cross(InRay.direction, e2);

            //if determinant is near zero, ray lies in plane of triangle
            float det = Vector3.Dot(e1, P);

            // Non-culling branch
            // {
            if (det > -Mathf.Epsilon && det < Mathf.Epsilon)
                return false;

            float inv_det = 1f / det;

            //calculate distance from V1 to ray origin
            Vector3 T = InRay.origin - InTriangleA;

            // Calculate u parameter and test bound
            float u = Vector3.Dot(T, P) * inv_det;

            //The intersection lies outside of the triangle
            if (u < 0f || u > 1f)
                return false;

            //Prepare to test v parameter
            Vector3 Q = Vector3.Cross(T, e1);

            //Calculate V parameter and test bound
            float v = Vector3.Dot(InRay.direction, Q) * inv_det;

            //The intersection lies outside of the triangle
            if (v < 0f || u + v  > 1f)
                return false;

            float t = Vector3.Dot(e2, Q) * inv_det;
            // }

            if (t > Mathf.Epsilon)
            {
                //ray intersection
                OutDistance = t;

                OutPoint.x = (u * InTriangleB.x + v * InTriangleC.x + (1 - (u + v)) * InTriangleA.x);
                OutPoint.y = (u * InTriangleB.y + v * InTriangleC.y + (1 - (u + v)) * InTriangleA.y);
                OutPoint.z = (u * InTriangleB.z + v * InTriangleC.z + (1 - (u + v)) * InTriangleA.z);

                return true;
            }

            return false;
        }

        // Temporary vector3 values
        static Vector3 tv1, tv2, tv3, tv4;

        /// <summary>
        /// Non-allocating version of Ray / Triangle intersection.
        /// </summary>
        /// <param name="origin"></param>
        /// <param name="dir"></param>
        /// <param name="vert0"></param>
        /// <param name="vert1"></param>
        /// <param name="vert2"></param>
        /// <param name="distance"></param>
        /// <param name="normal"></param>
        /// <returns></returns>
        internal static bool RayIntersectsTriangle2(Vector3 origin,
            Vector3 dir,
            Vector3 vert0,
            Vector3 vert1,
            Vector3 vert2,
            out float distance,
            out Vector3 normal)
        {
            Math.Subtract(vert0, vert1, ref tv1);
            Math.Subtract(vert0, vert2, ref tv2);

            normal = Vector3.Cross(tv1, tv2);
            distance = 0f;

            // backface culling
            if (Vector3.Dot(dir, normal) > 0)
                return false;

            Math.Cross(dir, tv2, ref tv4);
            float det = Vector3.Dot(tv1, tv4);

            if (det < Mathf.Epsilon)
                return false;

            Math.Subtract(vert0, origin, ref tv3);

            float u = Vector3.Dot(tv3, tv4);

            if (u < 0f || u > det)
                return false;

            Math.Cross(tv3, tv1, ref tv4);

            float v = Vector3.Dot(dir, tv4);

            if (v < 0f || u + v > det)
                return false;

            distance = Vector3.Dot(tv2, tv4) * (1f / det);

            // no hit if point is behind the ray origin
            return distance > 0f;
        }

        /// <summary>
        /// Return the secant of a radian.
        /// Equivalent to: `1f / cos(x)`.
        /// </summary>
        /// <param name="x">The radian to calculate the secant of.</param>
        /// <returns>The secant of radian x.</returns>
        public static float Secant(float x)
        {
            return 1f / Mathf.Cos(x);
        }

        /// <summary>
        /// Calculate the unit vector normal of 3 points.
        /// <br />
        /// Equivalent to: `B-A x C-A`
        /// </summary>
        /// <param name="p0">First point of the triangle.</param>
        /// <param name="p1">Second point of the triangle.</param>
        /// <param name="p2">Third point of the triangle.</param>
        /// <returns></returns>
        public static Vector3 Normal(Vector3 p0, Vector3 p1, Vector3 p2)
        {
            float   ax = p1.x - p0.x,
                    ay = p1.y - p0.y,
                    az = p1.z - p0.z,
                    bx = p2.x - p0.x,
                    by = p2.y - p0.y,
                    bz = p2.z - p0.z;

            Vector3 cross = Vector3.zero;

            Cross(ax, ay, az, bx, by, bz, ref cross.x, ref cross.y, ref cross.z);

            if (cross.magnitude < Mathf.Epsilon)
            {
                return new Vector3(0f, 0f, 0f); // bad triangle
            }
            else
            {
                cross.Normalize();
                return cross;
            }
        }

        /// <summary>
        /// Get the average normal of a set of individual triangles.
        /// If p.Length % 3 == 0, finds the normal of each triangle in a face and returns the average. Otherwise return the normal of the first three points.
        /// </summary>
        /// <param name="p"></param>
        /// <returns></returns>
        internal static Vector3 Normal(IList<Vector3> p)
        {
            if (p == null || p.Count < 3)
                return Vector3.zero;

            int c = p.Count;

            if (c % 3 == 0)
            {
                Vector3 nrm = Vector3.zero;
                for (int i = 0; i < c; i += 3)
                    nrm += Normal(p[i + 0], p[i + 1], p[i + 2]);
                nrm /= (c / 3f);
                nrm.Normalize();
                return nrm;
            }
            Vector3 cross = Vector3.Cross(p[1] - p[0], p[2] - p[0]);

            if (cross.magnitude < Mathf.Epsilon)
                return new Vector3(0f, 0f, 0f); // bad triangle

            return cross.normalized;
        }

        /// <summary>
        /// Gets the average of a vector array.
        /// </summary>
        /// <param name="array">The array</param>
        /// <param name="indexes">If provided the average is the sum of all points contained in the indexes array. If not, the entire v array is used.</param>
        /// <returns>Average Vector3 of passed vertex array.</returns>
        public static Vector2 Average(IList<Vector2> array, IList<int> indexes = null)
        {
            if (array == null)
                throw new ArgumentNullException("array");

            Vector2 sum = Vector2.zero;
            float len = indexes == null ? array.Count : indexes.Count;

            if (indexes == null)
                for (int i = 0; i < len; i++) sum += array[i];
            else
                for (int i = 0; i < len; i++) sum += array[indexes[i]];

            return sum / len;
        }

        /// <summary>
        /// Gets the average of a vector array.
        /// </summary>
        /// <param name="array">The array.</param>
        /// <param name="indexes">If provided the average is the sum of all points contained in the indexes array. If not, the entire v array is used.</param>
        /// <returns>Average Vector3 of passed vertex array.</returns>
        public static Vector3 Average(IList<Vector3> array, IList<int> indexes = null)
        {
            if (array == null)
                throw new ArgumentNullException("array");

            Vector3 sum = Vector3.zero;

            float len = indexes == null ? array.Count : indexes.Count;

            if (indexes == null)
            {
                for (int i = 0; i < len; i++)
                {
                    sum.x += array[i].x;
                    sum.y += array[i].y;
                    sum.z += array[i].z;
                }
            }
            else
            {
                for (int i = 0; i < len; i++)
                {
                    sum.x += array[indexes[i]].x;
                    sum.y += array[indexes[i]].y;
                    sum.z += array[indexes[i]].z;
                }
            }

            return sum / len;
        }

        /// <summary>
        /// Average a set of vertices.
        /// </summary>
        /// <param name="list">The collection from which to select indices.</param>
        /// <param name="selector">The function used to get vertex values.</param>
        /// <param name="indexes"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        internal static Vector3 Average<T>(this IList<T> list, Func<T, Vector3> selector, IList<int> indexes = null)
        {
            if (list == null)
                throw new ArgumentNullException("list");

            if (selector == null)
                throw new ArgumentNullException("selector");

            Vector3 sum = Vector3.zero;
            float len = indexes == null ? list.Count : indexes.Count;

            if (indexes == null)
            {
                for (int i = 0; i < len; i++)
                    sum += selector(list[i]);
            }
            else
            {
                for (int i = 0; i < len; i++)
                    sum += selector(list[indexes[i]]);
            }

            return sum / len;
        }

        /// <summary>
        /// Average a set of Vector4.
        /// </summary>
        /// <param name="v">The collection from which to select indices.</param>
        /// <param name="indexes">The indexes to use to compute the average value</param>
        /// <returns>Average Vector4 from selected values</returns>
        public static Vector4 Average(IList<Vector4> v, IList<int> indexes = null)
        {
            if (v == null)
                throw new ArgumentNullException("v");

            Vector4 sum = Vector4.zero;
            float len = indexes == null ? v.Count : indexes.Count;
            if (indexes == null)
                for (int i = 0; i < len; i++) sum += v[i];
            else
                for (int i = 0; i < len; i++) sum += v[indexes[i]];
            return sum / len;
        }

        internal static Color Average(IList<Color> c, IList<int> indexes = null)
        {
            if (c == null)
                throw new ArgumentNullException("c");

            Color sum = c[0];
            float len = indexes == null ? c.Count : indexes.Count;
            if (indexes == null)
                for (int i = 1; i < len; i++) sum += c[i];
            else
                for (int i = 1; i < len; i++) sum += c[indexes[i]];
            return sum / len;
        }

        /// <summary>
        /// Compares two Vector2 values component-wise, allowing for a margin of error.
        /// </summary>
        /// <param name="a">First Vector2 value.</param>
        /// <param name="b">Second Vector2 value.</param>
        /// <param name="delta">The maximum difference between components allowed.</param>
        /// <returns>True if a and b components are respectively within delta distance of one another.</returns>
        internal static bool Approx2(this Vector2 a, Vector2 b, float delta = k_FltCompareEpsilon)
        {
            return
                Mathf.Abs(a.x - b.x) < delta &&
                Mathf.Abs(a.y - b.y) < delta;
        }

        /// <summary>
        /// Compares two Vector3 values component-wise, allowing for a margin of error.
        /// </summary>
        /// <param name="a">First Vector3 value.</param>
        /// <param name="b">Second Vector3 value.</param>
        /// <param name="delta">The maximum difference between components allowed.</param>
        /// <returns>True if a and b components are respectively within delta distance of one another.</returns>
        internal static bool Approx3(this Vector3 a, Vector3 b, float delta = k_FltCompareEpsilon)
        {
            return
                Mathf.Abs(a.x - b.x) < delta &&
                Mathf.Abs(a.y - b.y) < delta &&
                Mathf.Abs(a.z - b.z) < delta;
        }

        /// <summary>
        /// Compares two Vector4 values component-wise, allowing for a margin of error.
        /// </summary>
        /// <param name="a">First Vector4 value.</param>
        /// <param name="b">Second Vector4 value.</param>
        /// <param name="delta">The maximum difference between components allowed.</param>
        /// <returns>True if a and b components are respectively within delta distance of one another.</returns>

        internal static bool Approx4(this Vector4 a, Vector4 b, float delta = k_FltCompareEpsilon)
        {
            return
                Mathf.Abs(a.x - b.x) < delta &&
                Mathf.Abs(a.y - b.y) < delta &&
                Mathf.Abs(a.z - b.z) < delta &&
                Mathf.Abs(a.w - b.w) < delta;
        }

        /// <summary>
        /// Compares two Color values component-wise, allowing for a margin of error.
        /// </summary>
        /// <param name="a">First Color value.</param>
        /// <param name="b">Second Color value.</param>
        /// <param name="delta">The maximum difference between components allowed.</param>
        /// <returns>True if a and b components are respectively within delta distance of one another.</returns>
        internal static bool ApproxC(this Color a, Color b, float delta = k_FltCompareEpsilon)
        {
            return Mathf.Abs(a.r - b.r) < delta &&
                Mathf.Abs(a.g - b.g) < delta &&
                Mathf.Abs(a.b - b.b) < delta &&
                Mathf.Abs(a.a - b.a) < delta;
        }

        /// <summary>
        /// Compares two float values component-wise, allowing for a margin of error.
        /// </summary>
        /// <param name="a">First float value.</param>
        /// <param name="b">Second float value.</param>
        /// <param name="delta">The maximum difference between components allowed.</param>
        /// <returns>True if a and b components are respectively within delta distance of one another.</returns>

        internal static bool Approx(this float a, float b, float delta = k_FltCompareEpsilon)
        {
            return Mathf.Abs(b - a) < Mathf.Abs(delta);
        }

        /// <summary>
        /// Wrap value to range.
        /// </summary>
        /// <remarks>
        /// http://stackoverflow.com/questions/707370/clean-efficient-algorithm-for-wrapping-integers-in-c
        /// </remarks>
        /// <param name="value"></param>
        /// <param name="lowerBound"></param>
        /// <param name="upperBound"></param>
        /// <returns></returns>
        internal static int Wrap(int value, int lowerBound, int upperBound)
        {
            int range_size = upperBound - lowerBound + 1;

            if (value < lowerBound)
                value += range_size * ((lowerBound - value) / range_size + 1);

            return lowerBound + (value - lowerBound) % range_size;
        }

        /// <summary>
        /// Clamp a int to a range.
        /// </summary>
        /// <param name="value">The value to clamp.</param>
        /// <param name="lowerBound">The lowest value that the clamped value can be.</param>
        /// <param name="upperBound">The highest value that the clamped value can be.</param>
        /// <returns>A value clamped with the range of lowerBound and upperBound.</returns>
        public static int Clamp(int value, int lowerBound, int upperBound)
        {
            return value<lowerBound? lowerBound : value> upperBound ? upperBound : value;
        }

        internal static Vector3 ToSignedMask(this Vector3 vec, float delta = k_FltEpsilon)
        {
            return new Vector3(
                Mathf.Abs(vec.x) > delta ? vec.x / Mathf.Abs(vec.x) : 0f,
                Mathf.Abs(vec.y) > delta ? vec.y / Mathf.Abs(vec.y) : 0f,
                Mathf.Abs(vec.z) > delta ? vec.z / Mathf.Abs(vec.z) : 0f
                );
        }

        internal static Vector3 Abs(this Vector3 v)
        {
            return new Vector3(Mathf.Abs(v.x), Mathf.Abs(v.y), Mathf.Abs(v.z));
        }

        internal static int IntSum(this Vector3 mask)
        {
            return (int)Mathf.Abs(mask.x) + (int)Mathf.Abs(mask.y) + (int)Mathf.Abs(mask.z);
        }

        /// <summary>
        /// Non-allocating cross product.
        /// </summary>
        /// <remarks>
        /// `ref` does not box with primitive types (https://msdn.microsoft.com/en-us/library/14akc2c7.aspx)
        /// </remarks>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="z"></param>
        internal static void Cross(Vector3 a, Vector3 b, ref float x, ref float y, ref float z)
        {
            x = a.y * b.z - a.z * b.y;
            y = a.z * b.x - a.x * b.z;
            z = a.x * b.y - a.y * b.x;
        }

        /// <summary>
        /// Non-allocating cross product.
        /// </summary>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <param name="res"></param>
        internal static void Cross(Vector3 a, Vector3 b, ref Vector3 res)
        {
            res.x = a.y * b.z - a.z * b.y;
            res.y = a.z * b.x - a.x * b.z;
            res.z = a.x * b.y - a.y * b.x;
        }

        /// <summary>
        /// Non-allocating cross product.
        /// </summary>
        /// <param name="ax"></param>
        /// <param name="ay"></param>
        /// <param name="az"></param>
        /// <param name="bx"></param>
        /// <param name="by"></param>
        /// <param name="bz"></param>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="z"></param>
        internal static void Cross(float ax, float ay, float az, float bx, float by, float bz, ref float x, ref float y, ref float z)
        {
            x = ay * bz - az * by;
            y = az * bx - ax * bz;
            z = ax * by - ay * bx;
        }

        internal static void Add(Vector3 a, Vector3 b, ref Vector3 res)
        {
            res.x = a.x + b.x;
            res.y = a.y + b.y;
            res.z = a.z + b.z;
        }

        /// <summary>
        /// Vector subtraction without allocating a new vector.
        /// </summary>
        /// <param name="a"></param>
        /// <param name="b"></param>
        /// <param name="res"></param>
        internal static void Subtract(Vector3 a, Vector3 b, ref Vector3 res)
        {
            res.x = b.x - a.x;
            res.y = b.y - a.y;
            res.z = b.z - a.z;
        }

        internal static void Divide(Vector3 vector, float value, ref Vector3 res)
        {
            res.x = vector.x / value;
            res.y = vector.y / value;
            res.z = vector.z / value;
        }

        internal static void Multiply(Vector3 vector, float value, ref Vector3 res)
        {
            res.x = vector.x * value;
            res.y = vector.y * value;
            res.z = vector.z * value;
        }

        internal static int Min(int a, int b)
        {
            return a < b ? a : b;
        }

        internal static int Max(int a, int b)
        {
            return a > b ? a : b;
        }

        internal static bool IsNumber(float value)
        {
            return !(float.IsInfinity(value) || float.IsNaN(value));
        }

        internal static bool IsNumber(Vector2 value)
        {
            return IsNumber(value.x) && IsNumber(value.y);
        }

        internal static bool IsNumber(Vector3 value)
        {
            return IsNumber(value.x) && IsNumber(value.y) && IsNumber(value.z);
        }

        internal static bool IsNumber(Vector4 value)
        {
            return IsNumber(value.x) && IsNumber(value.y) && IsNumber(value.z) && IsNumber(value.w);
        }

        internal static float MakeNonZero(float value, float min = .0001f)
        {
            if (float.IsNaN(value) || float.IsInfinity(value) || Mathf.Abs(value) < min)
                return min * Mathf.Sign(value);
            return value;
        }

        /// <summary>
        /// True if all elements of a vector are equal.
        /// </summary>
        /// <param name="vector"></param>
        /// <returns></returns>
        internal static bool VectorIsUniform(Vector3 vector)
        {
            return Mathf.Abs(vector.x - vector.y) < Mathf.Epsilon && Mathf.Abs(vector.x - vector.z) < Mathf.Epsilon;
        }

        /// <summary>
        /// Returns a weighted average from values "array", "indices", and a lookup table of index weights.
        /// </summary>
        /// <param name="array"></param>
        /// <param name="indices"></param>
        /// <param name="weightLookup"></param>
        /// <returns></returns>
        internal static Vector3 WeightedAverage(Vector3[] array, IList<int> indices, float[] weightLookup)
        {
            if (array == null || indices == null || weightLookup == null) return Vector3.zero;

            float sum = 0f;
            Vector3 avg = Vector3.zero;

            for (int i = 0; i < indices.Count; i++)
            {
                float weight = weightLookup[indices[i]];
                avg.x += array[indices[i]].x * weight;
                avg.y += array[indices[i]].y * weight;
                avg.z += array[indices[i]].z * weight;
                sum += weight;
            }
            return sum > Mathf.Epsilon ? avg /= sum : Vector3.zero;
        }
    }
}
