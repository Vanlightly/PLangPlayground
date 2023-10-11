enum tStatus {
    ALIVE,
    DEAD
}

enum tMsgType {
    REQ, RESP
}

type tGossip = (source: Node, dest: Node, msgType: tMsgType,
                peerState: map[Node, tStatus]);
event eSendGossip;
event eReceiveGossip : tGossip;
event eStop;
event eStart;
event eDetectDeadNode;

machine Node {
    var nodeId: int;
    var peerState: map[Node, tStatus];
    var running: bool;

    start state Running {
        on eInitPeerState do (ps: map[Node, tStatus]) {
            peerState = ps;
            running = true;
        }

        on eStop do {
            print "Stopping";
            running = false;
            goto Stopped;
        }

        on eSendGossip do {
            var peer: Node;

            print "Gossiping";

            peer = choose(keys(peerState));
            send peer, eReceiveGossip, (source = this,
                dest = peer, msgType = REQ,
                peerState = peerState);
        }

        on eReceiveGossip do (gossip: tGossip) {
            var newPeerState: map[Node, tStatus];
            var node: Node;

            print "Receiving gossip";

            foreach (node in keys(gossip.peerState))
            {
                if (node == this) {
                    newPeerState[node] = peerState[node];
                } else {
                    newPeerState[node] = gossip.peerState[node];
                }
            }
            peerState = newPeerState;

            if (gossip.msgType == REQ) {
                send gossip.source, eReceiveGossip, (source = this,
                                            dest = gossip.source,
                                            msgType = RESP,
                                            peerState = peerState);
            }
        }

        on eDetectDeadNode do {
            var alivePeers: set[Node];
            var node: Node;

            print "Detecting dead node";

            foreach (node in keys(peerState)) {
                if (peerState[node] == ALIVE && node != this) {
                    alivePeers += (node);
                }
            }

            if (sizeof(alivePeers) > 0) {
                peerState[choose(alivePeers)] = ALIVE;
            }
        }
    }

    state Stopped {
        on eStart do {
            print "Starting";
            running = true;
            goto Running;
        }
    }

    
}