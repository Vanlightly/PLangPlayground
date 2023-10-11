event eInitPeerState: map[Node, tStatus];

spec EventuallyConverges observes eReceiveGossip, eStart, eStop {
    var deadNodes: set[Node];
    var liveNodes: set[Node];
    var allPeerState: map[Node, map[Node, tStatus]];

    start state Converged {
        on eInitPeerState do (peerState: map[Node, tStatus]) {
            var node: Node;
            
            foreach (node in keys(peerState)) {
                liveNodes += (node);
                allPeerState[node] = peerState;
            }
        }

        on eStop do (node: machine) {
            deadNodes += (node as Node);
            liveNodes -= (node as Node);
            goto NotConverged;
        }

        on eStart do (node: machine) {
            liveNodes += (node as Node);
            deadNodes -= (node as Node);
            goto NotConverged;
        }

        on eReceiveGossip do(gossip: tGossip) {
            allPeerState[gossip.source] = gossip.peerState;

            if (!IsConverged()) {
                goto NotConverged;
            }
        }
    }

    hot state NotConverged {
        on eReceiveGossip do(gossip: tGossip) {
            allPeerState[gossip.source] = gossip.peerState;

            if (IsConverged()) {
                goto Converged;
            }
        }
    }

    fun IsConverged() : bool {
        var converged: bool;
        var n1: Node;
        var n2: Node;

        converged = true;
        foreach (n1 in keys(allPeerState)) {
            foreach (n2 in keys(allPeerState)) {
                if (allPeerState[n1][n2] == ALIVE && n2 in deadNodes) {
                    converged = false;
                } else if (allPeerState[n1][n2] == DEAD && n2 in liveNodes) {
                    converged = false;
                }
            }
        }

        return converged;
    }
}