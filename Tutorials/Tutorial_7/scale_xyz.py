#!/usr/bin/env python3

import argparse


def scale_xyz(input_file, output_file, scale):
    with open(input_file, "r") as f:
        lines = f.readlines()

    # First line: number of atoms
    natoms = int(lines[0].strip())

    # Second line: comment
    output_lines = lines[:2]

    # Scale coordinates
    for line in lines[2:2 + natoms]:
        parts = line.split()

        if len(parts) < 4:
            raise ValueError(f"Invalid XYZ line: {line!r}")

        atom = parts[0]
        x, y, z = map(float, parts[1:4])

        output_lines.append(
            f"{atom} {x * scale:.8f} {y * scale:.8f} {z * scale:.8f}\n"
        )

    with open(output_file, "w") as f:
        f.writelines(output_lines)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Multiply all XYZ coordinates by a constant."
    )
    parser.add_argument("input", help="Input XYZ file")
    parser.add_argument("output", help="Output XYZ file")
    parser.add_argument("scale", type=float, help="Coordinate scaling factor")

    args = parser.parse_args()

    scale_xyz(args.input, args.output, args.scale)

