module Problem_NQueens
{
  use List;

  use Problem;

  class Problem_NQueens : Problem
  {
    var N: int; // number of queens
    var timeStop: int;

    proc init(const n: int, const timeStop: int): void
    {
      this.N = n;
      this.timeStop = timeStop;
    }

    override proc copy()
    {
      return new Problem_NQueens(this.N, this.timeStop);
    }

    proc isSafe(const board, const queen_num: int, const row_pos: uint(8)): bool
    {
      // For each queen before this one
      for i in 0..#queen_num {
        // Get the row position
        const other_row_pos = board[i];

        // Check diagonals
        if (other_row_pos == row_pos - (queen_num - i) ||
            other_row_pos == row_pos + (queen_num - i)) {
          return false;
        }
      }

      return true;
    }

    override proc decompose(type Node, const parent: Node, ref tree_loc: int, ref num_sol: int,
      ref max_depth: int, ref best: int, lock: sync bool, ref best_task: int): list(?)
    {
      var children: list(Node);

      const depth = parent.depth;

      if (depth == this.N) { // All queens are placed
        num_sol += 1;
      }
      for j in depth..this.N-1 {
        if isSafe(parent.board, depth, parent.board[j]) {
          var child = new Node(parent);
          child.board[depth] <=> child.board[j];
          child.depth += 1;
          children.pushBack(child);
          tree_loc += 1;
        }
      }

      return children;
    }

    // No bounding in NQueens
    override proc getInitBound(): int
    {
      return 0;
    }

    override proc getType(): int
    {
      return 0;
    }

    override proc getTimeStop(): int
    {
      return this.timeStop;
    }

    // =======================
    // Utility functions
    // =======================

    override proc print_settings(): void
    {
      writeln("\n=================================================");
      writeln("Resolution of the ", this.N, "-Queens instance");
      writeln("=================================================");
    }

    override proc print_results(const subNodeExplored, const subSolExplored,
      const subDepthReached, const best: int, const elapsedTime: real, const bestBound: real): void
    {
      var treeSize, nbSol: int;

      if (isArray(subNodeExplored) && isArray(subSolExplored)) {
        treeSize = (+ reduce subNodeExplored);
        nbSol = (+ reduce subSolExplored);
      } else { // if not array, then int
        treeSize = subNodeExplored;
        nbSol = subSolExplored;
      }

      var par_mode: string = if (numLocales == 1) then "tasks" else "locales";

      writeln("\n=================================================");
      writeln("Size of the explored tree: ", treeSize);
      /* writeln("Size of the explored tree per locale: ", sizePerLocale); */
      if isArray(subNodeExplored) {
        writeln("% of the explored tree per ", par_mode, ": ", 100 * subNodeExplored:real / treeSize:real);
      }
      writeln("Number of explored solutions: ", nbSol);
      /* writeln("Number of explored solutions per locale: ", numSolPerLocale); */
      writeln("Elapsed time: ", elapsedTime, " [s]");
      writeln("=================================================\n");
    }

    override proc output_filepath(): string
    {
      return "./chpl_nqueens_" + this.N:string + ".txt";
    }

    override proc help_message(): void
    {
      writeln("\n  N-Queens Benchmark Parameter:\n");
      writeln("   --N   int   problem size (number of queens)\n");
    }

  } // end class

} // end module
