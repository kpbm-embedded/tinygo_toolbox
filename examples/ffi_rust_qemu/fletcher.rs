//! Fletcher-16 in no_std Rust, exported with the C ABI and linked into TinyGo firmware via cgo.
#![no_std]

/// # Safety
/// `p` must point to `n` readable bytes.
#[no_mangle]
pub unsafe extern "C" fn rust_fletcher16(p: *const u8, n: usize) -> u16 {
    let data = unsafe { core::slice::from_raw_parts(p, n) };
    let (mut a, mut b) = (0u16, 0u16);
    for &x in data {
        a = (a + x as u16) % 255;
        b = (b + a) % 255;
    }
    (b << 8) | a
}

#[panic_handler]
fn panic(_: &core::panic::PanicInfo) -> ! {
    loop {}
}
