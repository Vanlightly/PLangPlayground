

machine Receiver {
    var counter: int;

    start state Receive {
        on eCounter do (counter: int) {
            counter = counter;
        }
    }
}