#!/usr/bin/env python3
"""
도감 녹화 영상 → 선명한 대표 프레임 추출 (중복/흐림 제거).
사용: python3 extract_frames.py <video_path> [out_dir]
- 샘플링 fps로 프레임을 뽑고
- 라플라시안 분산으로 '흐린' 프레임 버리고
- 이전 유지 프레임과의 차이가 작으면(거의 동일 화면) 버림
=> Claude가 읽을 최소한의 distinct 프레임만 남긴다.
"""
import sys, os, cv2, numpy as np

def main(video, out_dir=None, sample_fps=2.0, blur_thresh=60.0, diff_thresh=6.0):
    name = os.path.splitext(os.path.basename(video))[0]
    out_dir = out_dir or os.path.join(os.path.dirname(video), "..", "frames", name)
    os.makedirs(out_dir, exist_ok=True)
    cap = cv2.VideoCapture(video)
    if not cap.isOpened():
        print("cannot open", video); return
    vfps = cap.get(cv2.CAP_PROP_FPS) or 30.0
    step = max(1, int(round(vfps / sample_fps)))
    idx = kept = 0
    prev_small = None
    while True:
        ok, frame = cap.read()
        if not ok: break
        if idx % step == 0:
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            fm = cv2.Laplacian(gray, cv2.CV_64F).var()          # 선명도
            small = cv2.resize(gray, (64, 36)).astype(np.float32)
            is_new = prev_small is None or float(np.mean(np.abs(small - prev_small))) > diff_thresh
            if fm >= blur_thresh and is_new:
                t = idx / vfps
                p = os.path.join(out_dir, f"{name}_{kept:03d}_{t:06.1f}s.png")
                cv2.imwrite(p, frame)
                kept += 1
                prev_small = small
        idx += 1
    cap.release()
    print(f"{name}: {kept} distinct frames -> {out_dir}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__); sys.exit(1)
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
