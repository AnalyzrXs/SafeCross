import math
from pathlib import Path

from lameenc import Encoder

SAMPLE_RATE = 44_100
AMPLITUDE = 0.7


def _build_wave(frequency: float, duration: float, pulsing: bool = False) -> bytes:
    total_samples = int(SAMPLE_RATE * duration)
    pcm = bytearray()
    for idx in range(total_samples):
        multiplier = 1.0
        if pulsing:
            envelope = 0.5 * (1 + math.sin(2 * math.pi * (idx / SAMPLE_RATE) * 3.25))
            multiplier = envelope
        sample = math.sin(2 * math.pi * frequency * (idx / SAMPLE_RATE)) * AMPLITUDE * multiplier
        value = int(max(-1.0, min(1.0, sample)) * 32767)
        pcm += value.to_bytes(2, byteorder="little", signed=True)
    return bytes(pcm)


def _write_mp3(path: Path, pcm_data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    encoder = Encoder()
    encoder.set_bit_rate(128)
    encoder.set_in_sample_rate(SAMPLE_RATE)
    encoder.set_channels(1)
    encoder.set_quality(7)
    mp3_data = encoder.encode(pcm_data)
    mp3_data += encoder.flush()
    path.write_bytes(mp3_data)


def main() -> None:
    root = Path(__file__).resolve().parents[1] / "assets" / "audio"
    cross_pcm = _build_wave(880.0, 1.4, pulsing=True)
    stop_pcm = _build_wave(440.0, 1.4, pulsing=False)
    _write_mp3(root / "cross.mp3", cross_pcm)
    _write_mp3(root / "stop.mp3", stop_pcm)


if __name__ == "__main__":
    main()
