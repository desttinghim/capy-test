const std = @import("std");
const capy = @import("capy");

// This is required for your app to build to WebAssembly and other particular architectures
pub usingnamespace capy.cross_platform;

// const TestStruct = struct {
//     int: capy.DataWrapper(u32) = capy.DataWrapper(u32).of(0),
// };
var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
var arena = std.heap.ArenaAllocator.init(general_purpose_allocator.allocator());
const allocator = arena.allocator();

pub fn main() !void {
    defer arena.deinit();
    try capy.backend.init();

    // var test_struct = TestStruct{};

    var window = try capy.Window.init();
    try window.set(
        capy.Column(.{ .spacing = 10 }, .{ // have 10px spacing between each column's element
            capy.Row(.{ .spacing = 5 }, .{ // have 5px spacing between each row's element
                capy.Button(.{ .label = "Save", .onclick = @ptrCast(*const fn (*anyopaque) anyerror!void, &buttonClicked) }),
                capy.Button(.{ .label = "Run", .onclick = buttonClicked2 }),
            }),
            // Expanded means the widget will take all the space it can
            // in the parent container
            capy.Expanded(capy.Label(.{ .text = "Hello World!" })),
        }),
    );

    window.resize(800, 600);
    window.show();

    std.log.info("Window shown!", .{});

    capy.runEventLoop();
}

fn buttonClicked(button: *capy.Button_Impl) anyerror!void {
    std.log.info("You clicked button with text {s}", .{button.getLabel()});
    // const new_text = try std.fmt.allocPrintZ(allocator, "You clicked button with text {s}", .{button.getLabel()});
    // button.setLabel(new_text);
}

fn buttonClicked2(_: *anyopaque) anyerror!void {
    std.log.info("You clicked button 2", .{});
}
