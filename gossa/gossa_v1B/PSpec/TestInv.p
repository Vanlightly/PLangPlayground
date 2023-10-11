spec TestInv observes eReceiveGossip, eStop {
    start state Wait {
        on eReceiveGossip do (gossip: tGossip) {
            var node: Node;

            foreach (node in keys(gossip.peerState)) {
                if (gossip.peerState[node] == DEAD) {
                    goto Bad;
                }
            }
        }

        on eStop do {
            goto Bad;
        }
    }

    hot state Bad {

    }
}