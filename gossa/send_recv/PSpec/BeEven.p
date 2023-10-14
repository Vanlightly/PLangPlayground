spec BeEven observes eCounter {
    start state Good {
        on eCounter do (counter: int) {
            if (counter % 2 == 1) {
                goto Bad;
            }
        }
    }

    hot state Bad {
        on eCounter do (counter: int) {
            if (counter % 2 == 0) {
                goto Good;
            }
        }
    }
}