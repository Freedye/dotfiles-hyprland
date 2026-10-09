import Quickshell

ShellRoot {
    Variants {
        model: {
            const wanted = Quickshell.screens.filter(s => s.name === Theme.barOutput);
            return wanted.length > 0 ? wanted : Quickshell.screens.slice(0, 1);
        }

        Bar {}
    }

    // confirmation dialog for shutdown / restart / logout, on every screen
    Variants {
        model: Quickshell.screens

        PowerDialog {}
    }
}
