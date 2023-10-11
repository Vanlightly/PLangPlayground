machine Test {
    start state Init {
        entry {
          // multiple nodes between (2, 6)
          SetupNodes(choose(4) + 2);
        }
      }
}

fun SetupNodes(numNodes: int)
{
    var i: int;
    var nodes: set[Node];
    var peerState: map[Node, tStatus];
    var node: Node;

    while (i < numNodes) {
        nodes += (new Node());
        i = i + 1;
    }

    foreach (node in nodes) {
        peerState[node] = ALIVE;
    }

    announce eInitPeerState, peerState;
}