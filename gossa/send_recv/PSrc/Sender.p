event eCounter: int;
event eNext;

machine Sender {
    var counter: int;
    var receiver: Receiver;

    start state Running {
        entry (recv: Receiver) {
            receiver = recv;
            send this, eNext;
        }

        on eNext do {
            counter = counter + 1;
            send receiver, eCounter, counter;
            send this, eNext;
        }
    }
}