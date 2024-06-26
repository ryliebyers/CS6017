
import std.stdio;

import std.math;
import std.container;
import common;

struct KDTree(size_t Dim){

    class Node(size_t splitDimension) {
    
        enum thisLevel = splitDimension; 
        enum nextLevel = (splitDimension + 1) % Dim;
        Node!nextLevel left, right;

        Point!Dim splitPoint;
        Point!Dim[] storedPoints;

        this(Point!Dim[] points) {
            // Base case
            if (points.length < 3) {
                storedPoints = points;
                return;
            }

            auto leftHalf = points.medianByDimension!thisLevel;
            auto rightHalf = points[leftHalf.length + 1 .. $];
            splitPoint = points[leftHalf.length];

            left = new Node!nextLevel(leftHalf);
            right = new Node!nextLevel(rightHalf);
        }
    }

   Node!0 root;

    this(Point!Dim[] points){
        root = new Node!0(points);
    }

    Point!Dim[] knnQuery(Point!Dim queryPoint, int k ) {
        auto ret = makePriorityQueue!Dim(queryPoint); 

        void recurse( size_t dim )(Node!dim n, AABB!Dim aabb) {
            // Check stored points
            if (isNaN(n.splitPoint[0])) {
                foreach(point; n.storedPoints) {
                    if (ret.length < k) {
                        ret.insert(point);
                    }
                    else if (distance(point, queryPoint) < distance(queryPoint, ret.front)) {
                        ret.popFront;
                        ret.insert(point); 
                    }
                }
            }
            else {
                // Check split point
                if (ret.length < k) {
                    ret.insert(n.splitPoint);
                }
                else if (distance(n.splitPoint, queryPoint) < distance(queryPoint, ret.front)) {
                    ret.popFront;
                    ret.insert(n.splitPoint); 
                }

                auto left_aabb = aabb;
                left_aabb.max[n.thisLevel] = n.splitPoint[n.thisLevel];
                if (ret.length < k || distance(queryPoint, closest(left_aabb, queryPoint)) < distance(queryPoint, ret.front)) {
                    recurse(n.left, left_aabb);
                }

                auto right_aabb = aabb;
                right_aabb.min[n.thisLevel] = n.splitPoint[n.thisLevel];
                if (ret.length < k || distance(queryPoint, closest(right_aabb, queryPoint)) < distance(queryPoint, ret.front)) {
                    recurse(n.right, right_aabb);
                }
            }
        }

        AABB!Dim root_aabb;
        foreach(i; 0 .. Dim){
            root_aabb.min[i] = -float.infinity;
            root_aabb.max[i] = float.infinity;
        }

        recurse!0(root, root_aabb);
        return ret.release;
    }

    
    Point!Dim[] rangeQuery( Point!Dim queryPoint, float radius ) {
        //return all points within a distance r of p
        Point!Dim[] ret;
        //void recurse( NodeType )( NodeType n )
        void recurse( size_t dim )(Node!dim n) {
            if (distance(n.splitPoint, queryPoint) < radius) {
                ret ~= n.splitPoint;
            }
            foreach(point; n.storedPoints) {
                if (distance(point, queryPoint) < radius) {
                    ret ~= point;
                }
            }

            if(n.left && queryPoint[n.thisLevel] - radius < n.splitPoint[n.thisLevel]) {
                recurse( n.left );
            }
            if(n.right&& queryPoint[n.thisLevel] + radius > n.splitPoint[n.thisLevel]) {
                recurse(n.right);
            }
        }
        recurse(root);
        return ret;
    }
}
unittest {
    // Initialize the KDTree with sample points
    auto kdTree = KDTree!2([Point!2([0.5, 0.5]), Point!2([1, 1]),
                            Point!2([0.75, 0.4]), Point!2([0.4, 0.74])]);

    // Print the KDTree structure for verification
    writeln(kdTree);

    // Perform a range query and print the results
    writeln("KDTree range query");
    foreach(p; kdTree.rangeQuery(Point!2([1, 1]), 0.7)) {
        writeln(p);
    }

    // Perform a KNN query and print the results
    writeln("KDTree KNN query");
    foreach(p; kdTree.knnQuery(Point!2([1, 1]), 3)) {
        writeln(p);
    }
}
