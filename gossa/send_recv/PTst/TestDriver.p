machine Test {
    start state Init {
        entry {
            var receiver: Receiver;
            receiver = new Receiver();
            new Sender(receiver);
        }
    }
}