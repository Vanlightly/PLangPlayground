test tcReachConvergence [main=Test]:
  assert EventuallyConverges, TestInv in
        (union Node, { Test });