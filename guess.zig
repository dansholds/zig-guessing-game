// NOTE: This was written using zig 0.14.0 which is a dev version.
// The code will not work with the latest stable version of zig.
// due to std.Random being introduced in this version.

const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const reader = stdin.reader();

    var buffer: [1024]u8 = undefined;

    // ugly prints, but I'm still learning zig.
    std.debug.print("Welcome to the Number Guessing Game!\n", .{});
    std.debug.print("I'm thinking of a number between 1 and 100.\n", .{});
    std.debug.print("You have 5 chances to guess the correct number.\n\n", .{});

    std.debug.print("Please select a difficulty level:\n", .{});
    std.debug.print("1. Easy (10 chances)\n", .{});
    std.debug.print("2. Medium (5 chances)\n", .{});
    std.debug.print("3. Hard (3 chances)\n\n", .{});

    std.debug.print("Enter your choice:\n", .{});

    // read the user input (took so SO long to figure this out)
    const read_diff = try reader.readUntilDelimiterOrEof(&buffer, '\n');
    const diff_str = read_diff orelse return error.InputError;
    var diff: u8 = undefined;
    diff = try std.fmt.parseInt(u8, diff_str, 10);

    // error handling for invalid diff selction
    if (diff < 1 or diff > 3) {
        std.debug.print("Invalid choice. Please select a valid difficulty level.\n", .{});
        return error.InvalidDifficulty;
    }

    // generate random number using std.Random https://ziglang.org/documentation/master/std/#std.Random
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    const number = rand.intRangeAtMost(u8, 0, 100);

    // set initial values for chances and guess
    var chances: u8 = 1;
    var guess: u8 = undefined;
    var maxchances: u8 = undefined;

    // Set max chances based on selected diff
    if (diff == 1) {
        maxchances = 10;
    } else if (diff == 2) {
        maxchances = 5;
    } else if (diff == 3) {
        maxchances = 3;
    }

    // main game loop
    while (chances <= maxchances) {
        std.debug.print("Enter your guess: ", .{});
        const read_bytes = try reader.readUntilDelimiterOrEof(&buffer, '\n');
        const guess_str = read_bytes orelse return error.InputError;
        guess = try std.fmt.parseInt(u8, guess_str, 10);

        if (guess == number) {
            std.debug.print("Correct!\n", .{});
            break;
        }
        // give clues based on guess
        if (guess < number) {
            std.debug.print("Too low!\n", .{});
        } else {
            std.debug.print("Too high!\n", .{});
        }
        chances += 1; //remove a chance if guess is wrong
    }

    if (guess != number) {
        std.debug.print("You used all your chances. The correct number was {}.\n", .{number});
    }
}
