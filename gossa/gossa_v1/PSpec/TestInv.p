spec TestInv observes eReceiveGossip {
    start state Init {
        on eReceiveGossip do (gossip: tGossip) {
            var node: Node;

            goto Bad;
            // foreach (node in keys(gossip.peerState)) {
            //     if (gossip.peerState[node] == DEAD) {
            //         goto Bad;
            //     }
            // }
        }
    }

    hot state Bad {

    }
}