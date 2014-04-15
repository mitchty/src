fn main() {
    let (port, chan): (Port<int>, Chan<int>) = Chan::new();

    do spawn {
        chan.send(10);
    }
    println(port.recv().to_str());
}
