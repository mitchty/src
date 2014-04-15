fn main(){
    println("serial");
    for num in range(0, 100) {
        println("Hello");
    }
    println("parallel");
    for num in range(0, 100) {
        do spawn {
            println("Hello");
        }
    }
}
