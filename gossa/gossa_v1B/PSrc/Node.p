enum tStatus {
    ALIVE,
    DEAD
}

enum tMsgType {
    REQ, RESP
}

type tGossip = (source: Node, dest: Node, msgType: tMsgType,
                peerState: map[Node, tStatus]);

event eNext;
event eStart;
event eStop;
event eReceiveGossip : tGossip;

machine Node {
    var nodeId: int;
    var peerState: map[Node, tStatus];
    var running: bool;
        
    start state Init {
        on eInitPeerState do (ps: map[Node, tStatus]) {
            peerState = ps;
            running = true;
            goto Running;
        }
    }

    state Running {
        entry {
            send this, eNext;
        }

        on eNext do {
            var action: int;
            action = choose(3);
                        
            if (action == 0) {
                send this, eStop;
                goto Stopping;
            } else if (action == 1) {
                sendGossip(); 
            } else {
                detectDeadNode();
                send this, eNext;
            }
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
            } else {
                send this, eNext;
            }
        }
    }

    state Stopping {
        on eStop do {
            running = false;
            goto Stopped;
        }
    }
    
    state Stopped {
        entry {
            send this, eStart;
        }
    
        on eStart do {
            print "Starting";
            running = true;
            goto Running;
        }
    }

    fun sendGossip() {
        var peer: Node;

        print "Gossiping";

        peer = choose(keys(peerState));
        send peer, eReceiveGossip, (source = this,
            dest = peer, msgType = REQ,
            peerState = peerState);
    }

    fun detectDeadNode() {
        var alivePeers: set[Node];
        var node: Node;

        print "Detecting dead node";

        foreach (node in keys(peerState)) {
            if (peerState[node] == ALIVE && node != this) {
                alivePeers += (node);
            }
        }

        if (sizeof(alivePeers) > 0) {
            peerState[choose(alivePeers)] = DEAD;
        }
    }
}