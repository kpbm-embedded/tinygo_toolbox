//! Saturating PI controller in no_std Rust, exported with the C ABI for TinyGo (cgo).
#![no_std]

#[repr(C)]
pub struct Pi {
    kp: i32,
    ki: i32,
    integ: i32,
    limit: i32,
}

/// # Safety
/// `p` must point to a writable `Pi`.
#[no_mangle]
pub unsafe extern "C" fn pi_init(p: *mut Pi, kp: i32, ki: i32, limit: i32) {
    unsafe { *p = Pi { kp, ki, integ: 0, limit } };
}

/// Output in the same unit as the error; gains are in 1/16.
/// # Safety
/// `p` must point to a `Pi` set up by `pi_init`.
#[no_mangle]
pub unsafe extern "C" fn pi_step(p: *mut Pi, err: i32) -> i32 {
    let p = unsafe { &mut *p };
    p.integ = limit(p.integ.saturating_add(err), p.limit.saturating_mul(16));
    let out = p.kp.saturating_mul(err).saturating_add(p.ki.saturating_mul(p.integ) / 16) / 16;
    limit(out, p.limit)
}

// Not i32::clamp: it asserts min <= max, and any possible panic pulls core::fmt into the object, which
// `--emit obj` does not contain (the link then fails with undefined core::fmt symbols).
fn limit(v: i32, l: i32) -> i32 {
    if v > l {
        l
    } else if v < -l {
        -l
    } else {
        v
    }
}

#[panic_handler]
fn panic(_: &core::panic::PanicInfo) -> ! {
    loop {}
}
