/* The Computer Language Benchmarks Game
   https://salsa.debian.org/benchmarksgame-team/benchmarksgame/

   contributed by Casey Battaglino, Ben Harshbarger, and Brad Chamberlain
   derived from the GNU C version by Jeremy Zerfas
*/


use DynamicIters;

config const n = 10;         // the maximum tree depth

proc main() {
  const minDepth = 4,                      // the shallowest tree
        maxDepth = max(minDepth + 2, n),   // the deepest normal tree
        strDepth = maxDepth + 1,           // the depth of the "stretch" tree
        depths = minDepth..maxDepth by 2;  // the range of depths to create

  //
  // Create the short-lived "stretch" tree, checksum it, and print its stats.
  //
  {
    const strTree = new Tree(strDepth);
    writeln("stretch tree of depth ", strDepth, "\t check: ", strTree.sum());
  }

  //
  // Build the long-lived tree.
  //
  const llTree = new Tree(maxDepth);

  //
  // Iterate over the depths in parallel, dynamically assigning them
  // to tasks.  At each depth, create the required trees, compute
  // their sums, and free them.
  //
  for depth in dynamic(depths) {
    const iterations = 2**(maxDepth - depth + minDepth);
    var sum = 0;
    for i in 1..iterations {
      const t = new Tree(depth);
      sum += t.sum();
    }
    writeln(iterations, "\t trees of depth ", depth, "\t check: ", sum);
  }

  //
  // Checksum the long-lived tree, print its stats, and free it.
  //
  writeln("long lived tree of depth ", maxDepth, "\t check: ", llTree.sum());
}


//
// A simple balanced tree node class
//
class Tree {
  var left, right: unmanaged Tree?;

  //
  // A Tree-building initializer
  //
  proc init(depth) {
    if depth > 0 {
      left  = new unmanaged Tree(depth-1);
      right = new unmanaged Tree(depth-1);
    }
  }

  proc deinit() {
    delete left, right;
  }

  //
  // Add up tree node, freeing as we go
  //
  proc sum(): int {
    var sum = 1;
    if left {
      sum += left!.sum() + right!.sum();      
    }
    return sum;
  }
}
