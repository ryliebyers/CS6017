import std.stdio;

import common;
import dumbknn;
import bucketknn;
import quadtree;
import KDtree;



void main() {
    // Configuration
    int[] ks = [1, 5, 10, 20, 50]; // Different k values
    int[] Ns = [100, 500, 1000, 5000, 10000]; // Different N values
    int[] Ds = [1, 2, 3, 4, 5, 6, 7, 8]; // Different D values
    int numQueries = 100; // Number of KNN queries to run
    int numTrials = 3; // Number of trials for each experiment

    // File for DumbKNN results
   /* {
        File f = File("DumbKNN.csv", "w");
        f.writeln("DumbKNN,Dim,N,K,Time");
        static foreach(dim; 1..8) {{
            foreach(N; Ns) {
                auto trainingPoints = getGaussianPoints!dim(N);
                auto testingPoints = getUniformPoints!dim(numQueries);
                auto dumb = DumbKNN!dim(trainingPoints);
                foreach(k; ks) {{
                    auto totalTimes = 0.0;
                    foreach(trial; 0 .. numTrials) {
                        auto sw = StopWatch(AutoStart.no);
                        sw.start;
                        foreach(const ref qp; testingPoints) {
                            dumb.knnQuery(qp, k);
                        }
                        sw.stop;
                        totalTimes += sw.peek.total!"usecs";
                    }
                    auto avgTime = totalTimes / numTrials;
                    f.writeln("DumbKNN", ",", dim, ",", N, ",", k, ",", avgTime);
                }}
            }
        }}
        f.close();
    }
    */

    // File for BucketKNN results
   /* {
        File f = File("BucketKNN.csv", "w");
        f.writeln("BucketKNN,Dim,N,K,Time");
        static foreach(dim; 1..8) {{
            foreach(N; Ns) {{
                auto trainingPoints = getGaussianPoints!dim(N);
                auto testingPoints = getUniformPoints!dim(numQueries);
                auto bucket = BucketKNN!dim(trainingPoints, cast(int)pow(N / 64, 1.0 / dim)); // rough estimate to get 64 points per cell on average
                foreach(k; ks) {{
                    auto totalTimes = 0.0;
                    foreach(trial; 0 .. numTrials) {
                        auto sw = StopWatch(AutoStart.no);
                        sw.start;
                        foreach(const ref qp; testingPoints) {
                            bucket.knnQuery(qp, k);
                        }
                        sw.stop;
                        totalTimes += sw.peek.total!"usecs";
                    }
                    auto avgTime = totalTimes / numTrials;
                    f.writeln("BucketKNN", ",", dim, ",", N, ",", k, ",", avgTime);
                }}
            }}
        }}
        f.close();
    }
*/
    // File for Quadtree results (only for D=2)
    {
        File f = File("Quadtree.csv", "w");
        f.writeln("Quadtree,Dim,N,K,Time");
        static foreach(dim; 1..8) {{
        foreach(N; Ns) {{
            auto trainingPoints = getGaussianPoints!2(N);
            auto testingPoints = getUniformPoints!2(numQueries);
            auto qt = QuadTree!dim(trainingPoints);
           // auto qt = QuadTree(trainingPoints);
            foreach(k; ks) {{
                auto totalTimes = 0.0;
                foreach(trial; 0 .. numTrials) {
                    auto sw = StopWatch(AutoStart.no);
                    sw.start;
                    foreach(const ref qp; testingPoints) {
                        qt.knnQuery(qp, k);
                    }
                    sw.stop;
                    totalTimes += sw.peek.total!"usecs";
                }
                auto avgTime = totalTimes / numTrials;
                f.writeln("Quadtree", ",", 2, ",", N, ",", k, ",", avgTime);
            }}
        }}
        }}
        f.close();
    }

    // File for KDTree results
    {
        File f = File("KDTree.csv", "w");
        f.writeln("KDTree,Dim,N,K,Time");
        static foreach(dim; 1..8) {{
            foreach(N; Ns) {{
                auto trainingPoints = getGaussianPoints!dim(N);
                auto testingPoints = getUniformPoints!dim(numQueries);
                auto kd = KDTree!dim(trainingPoints);
                foreach(k; ks) {{
                    auto totalTimes = 0.0;
                    foreach(trial; 0 .. numTrials) {
                        auto sw = StopWatch(AutoStart.no);
                        sw.start;
                        foreach(const ref qp; testingPoints) {
                            kd.knnQuery(qp, k);
                        }
                        sw.stop;
                        totalTimes += sw.peek.total!"usecs";
                    }
                    auto avgTime = totalTimes / numTrials;
                    f.writeln("KDTree", ",", dim, ",", N, ",", k, ",", avgTime);
                }}
            }}
        }}
        f.close();
    }
}