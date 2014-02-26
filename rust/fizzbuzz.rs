fn is_three(num: int) -> bool {
    return  num % 3 == 0;
}

fn is_five(num: int) -> bool {
    return  num % 5 == 0;
}

fn main() {
    for num in range(1,101) {
        let mut answer = ~"";
        if is_three(num) {
            answer = answer + "Fizz";
        }
        if is_five(num){
            answer = answer + "Buzz";
        }
        if answer == ~""{
            println(num.to_str());
        } else {
           println(num.to_str() + " " + answer);
        }
    }
}

#[test]
fn test_is_three() {
    assert!(is_three(3))
    assert!(!is_three(1))
}

#[test]
fn test_is_five() {
    assert!(is_five(5))
    assert!(!is_five(1))
}
