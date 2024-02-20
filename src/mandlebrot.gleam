import gleam/io
import gleam/float
import gleam/order
import gleam/int

pub type Complex {
  Complex(real: Float, imaj: Float)
}

pub fn complex_mul(a: Complex, b: Complex) -> Complex {
  Complex(
    a.real *. b.real -. a.imaj *. b.imaj,
    a.real *. b.imaj +. a.imaj *. b.real,
  )
}

pub fn complex_add(a: Complex, b: Complex) -> Complex {
  Complex(a.real +. b.real, a.imaj +. b.imaj)
}

pub fn complex_mag_sq(a: Complex) -> Float {
  a.real *. a.real +. a.real *. a.real
}

pub type RangeRemap {
  RangeRemapper(from: #(Float, Float), to: #(Float, Float))
}

pub fn remap_range(value: Float, remapper: RangeRemap) -> Float {
  let from = remapper.from
  let to = remapper.to
  to.0 +. { value -. from.0 } *. { to.1 -. to.0 } /. { from.1 -. from.0 }
}

pub fn mandlebrot(c: Complex, z: Complex, iter: Int) -> Result(Nil, Int) {
  case float.compare(complex_mag_sq(z), 10_000.0) {
    // we've diverged
    order.Gt -> Error(iter)
    order.Eq | order.Lt -> {
      case int.compare(iter, 1000) {
        order.Eq | order.Gt -> {
          Ok(Nil)
        }
        order.Lt -> {
          mandlebrot(c, complex_add(complex_mul(z, z), c), iter + 1)
        }
      }
    }
  }
}

pub fn mandlebrot_base(c: Complex) -> Result(Nil, Int) {
  mandlebrot(c, Complex(0.0, 0.0), 0)
}

import gleam/list

pub fn main() {
  float.sum([1.0, 2.0, 3.0])
  let cmplx = Complex(0.0, 0.0)

  let width = 160 * 8
  let height = 50 * 8

  let x_remap =
    RangeRemapper(from: #(0.0, int.to_float(width)), to: #(-2.0, 1.0))
  let y_remap =
    RangeRemapper(from: #(0.0, int.to_float(height)), to: #(-1.0, 1.0))

  list.range(0, height)
  |> list.map(int.to_float)
  |> list.map(fn(row) {
    list.range(0, width)
    |> list.map(int.to_float)
    |> list.map(fn(col) {
      // io.println(
      //   col
      //   |> remap_range(x_remap)
      //   |> float.to_string,
      // )
      case
        mandlebrot_base(Complex(
          remap_range(col, x_remap),
          remap_range(row, y_remap),
        ))
      {
        Ok(_) -> io.print("·")
        Error(e) -> {
          let res = case [e >= 5, e >= 35, e >= 25] {
            [_, True, True] -> "+"
            [_, _, True] -> "@"
            _ -> " "
          }
          io.print(res)
        }
      }
    })
    io.println("")
  })
}
