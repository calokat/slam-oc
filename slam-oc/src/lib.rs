use std::fs;
use std::fs::File;
use std::io::Write;
use std::path::Path;

use godot::classes::image::Format;
use godot::classes::Image;
use godot::classes::Texture2D;
use godot::global::lerp;
use godot::obj::NewAlloc;
use godot::prelude::*;
use godot::classes::Sprite2D;
use godot::classes::ISprite2D;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}

#[derive(GodotClass)]
#[class(base=Sprite2D)]
struct Player {
    speed: f64,
    angular_speed: f64,
    base: Base<Sprite2D>
}

#[godot_api]
impl ISprite2D for Player {
    fn init(base: Base<Sprite2D>) -> Self {
        godot_print!("Hello, world!");

        Self {
            speed: 10.,
            angular_speed: std::f64::consts::PI,
            base
        }
    }

    fn physics_process(&mut self, delta: f64) {
        let radians = (self.angular_speed * delta) as f32;
        self.base_mut().rotate(radians);
    }
}

#[derive(GodotClass)]
#[class(base=Node)]
struct MotionInterpolator {
    buffer: Option<[Vector3; 4]>,
    staged_position: Option<Vector3>,
    base: Base<Node>
}

#[godot_api]
impl INode for MotionInterpolator {
    fn init(base: Base<Node>) -> Self {
        Self {
            buffer: None,
            staged_position: None,
            base
        }
    }
}

#[godot_api]
impl MotionInterpolator {
    #[func]
    fn load_buffer(&mut self, positions: [Vector3; 4]) {
        self.buffer = Some(positions);
    }

    #[func]
    fn push_position(&mut self, position: Vector3) {
        let mut buffer = self.buffer.expect("Buffer is not loaded!");

        match self.staged_position {
            Some(pos) => {
                let y = buffer[1];
                let z = buffer[2];
                let w = buffer[3];

                buffer[0] = y;
                buffer[1] = z;
                buffer[2] = w;
                buffer[3] = pos;

                self.buffer = Some(buffer);

                self.staged_position = Some(position);
            },
            None => {
                self.staged_position = Some(position);
            }
        }
    }

    fn spline1(&self, t: f32) -> Vector3 {
        let buffer = self.buffer.expect("Buffer is not loaded!");
        let anchor1 = lerp(&buffer[0].to_variant(), &buffer[1].to_variant(), &t.to_variant());
        let anchor2 = lerp(&buffer[1].to_variant(), &buffer[2].to_variant(), &t.to_variant());

        lerp(&anchor1, &anchor2, &t.to_variant()).to()
    }

    fn spline2(&self, t: f32) -> Vector3 {
        let buffer = self.buffer.expect("Buffer is not loaded!");
        let anchor1 = lerp(&buffer[1].to_variant(), &buffer[2].to_variant(), &t.to_variant());
        let anchor2 = lerp(&buffer[2].to_variant(), &buffer[3].to_variant(), &t.to_variant());

        lerp(&anchor1, &anchor2, &t.to_variant()).to()
    }


    #[func]
    fn interpolate(&self, t: f32) -> Vector3 {
        match self.staged_position {
            Some(_) => {
                let spline1pos = self.spline1(t/2. + 1./2.);
                let spline2pos = self.spline2(t/2.);

                lerp(&spline1pos.to_variant(), &spline2pos.to_variant(), &t.to_variant()).to()
            },
            None => {
                self.spline1(t/2.)
            }
        }
    }
}

#[derive(GodotClass)]
#[class(base=Node)]
struct Accelerometer {
    position_buffer: Vec<Vector3>,
    base: Base<Node>
}

#[godot_api]
impl INode for Accelerometer {
    fn init(base: Base<Node>) -> Self {
        Self {
            position_buffer: Vec::new(),
            base
        }
    }
}

#[godot_api]
impl Accelerometer {
    #[func]
    fn push_position(&mut self, position: Vector3) {
        self.position_buffer.push(position);
        if self.position_buffer.len() > 3 {
            self.position_buffer.remove(0);
        }
    }

    #[func]
    fn measure(&self, poll_rate: f32) -> Vector3 {
        if self.position_buffer.len() < 3 {
            return Vector3::ZERO
        }

        let vel1 = (self.position_buffer[1] - self.position_buffer[0])*poll_rate;
        let vel2 = (self.position_buffer[2] - self.position_buffer[1])*poll_rate;
        let acc = (vel2 - vel1)*poll_rate;
        
        acc
    }
}

#[derive(GodotClass)]
#[class(base=Node)]
struct SlamInstance {
    base: Base<Node>
}

#[godot_api]
impl INode for SlamInstance {
    fn init(base: Base<Node>) -> Self {
        Self {
            base
        }
    }
}

#[godot_api]
impl SlamInstance {
    #[func]
    fn sense(&self, img: PackedByteArray, acceleration: Vector3) {
        let img_bytes = img.to_vec();
        let path = Path::new("/tmp/slam-oc");

        fs::create_dir_all(path).expect("could not create directories at path!");
        let mut img_file = File::create(path.join("image.png")).expect("could not create file!");
        img_file.write_all(&img_bytes).expect("could not write image bytes!");
    }
}