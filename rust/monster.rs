trait Monster {
    fn attack(&self);
}

struct IndustrialRaverMonkey { strength: int }
struct AnnoyingUnixAdmin     { strength: int }
struct GothKid         { strength: int }
struct SpittingLlama         { strength: int }
struct ScreamingChildOnPlane { strength: int }
struct PersonInLineWithCoupons { strength: int }

impl Monster for IndustrialRaverMonkey {
    fn attack(&self) {
        println(fmt!("The monkey attacks for %d.", self.strength))
    }
    fn new() -> IndustrialRaverMonkey {
        IndustrialRaverMonkey {strength: 30}
    }
}

impl Monster for AnnoyingUnixAdmin {
    fn attack(&self) {
        println(fmt!("The annoying admin attacks for %d.", self.strength))
    }
}

impl Monster for GothKid {
    fn attack(&self) {
        println(fmt!("The gothic kid attacks for %d.", self.strength))
    }
}

impl Monster for SpittingLlama {
    fn attack(&self) {
        println(fmt!("The llama spit attacks for %d.", self.strength))
    }
}

impl Monster for ScreamingChildOnPlane {
    fn attack(&self) {
        println(fmt!("The child next to you on the plane scream attacks for %d.", self.strength))
    }
}

impl Monster for PersonInLineWithCoupons {
    fn attack(&self) {
        println(fmt!("The person in line in front of you uses coupons and attacks for %d.", self.strength))
    }
}

impl Monster for int {
    fn attack(&self) {
        println(fmt!("The integer attacks for %d.", *self))
    }
}

fn main() {
    let i = 10;
    let monkey = IndustrialRaverMonkey {strength: 35};
    let annoying_admin = AnnoyingUnixAdmin {strength: 1};
    let goth_dude = GothKid {strength: 1};
    let llama = SpittingLlama {strength: 2};
    let child = ScreamingChildOnPlane {strength: 9001};
    let coupon_addict = PersonInLineWithCoupons {strength: 100};

    let monster_vec = [&i,
                       &monkey,
                       &annoying_admin,
                       &goth_dude,
                       &llama,
                       &child,
                       &coupon_addict,
                       ];

    i.attack();
    monkey.attack();
    annoying_admin.attack();
    goth_dude.attack();
    llama.attack();
    child.attack();
    coupon_addict.attack();
}
