apiVersion: batch/v1
kind: Job
metadata:
  name: benchmark-job
spec:
  template:
    spec:
      containers:
      - name: benchmark
        image: lmcache/lmcache-benchmark:sha-a306df2
 # Replace with your actual image
        workingDir: /app
        command:
        - /bin/bash
        - -c
        - |
          set -euo pipefail
          echo "machine oss.navercorp.com login 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 password x-oauth-basic" > ~/.netrc
          chmod 600 ~/.netrc
          rm -rf /app
          git clone https://oss.navercorp.com/jaeeun-kil/LMBenchmark /app
          . ~/.bashrc || true
          . .venv/bin/activate || true
          /app/run_benchmarks.sh "$MODEL" "$BASE_URL" "$SAVE_FILE_KEY" "$SCENARIOS" "$QPS_VALUES"
        env:
        - name: HF_TOKEN
          value : "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
        - name: MODEL
          value: "meta-llama/Llama-3.1-8B-Instruct"
        - name: BASE_URL
          value: "http://10.233.105.222:8000"  # Replace with your actual service name
        - name: SAVE_FILE_KEY
          value: "benchmark_results"
        - name: SCENARIOS
          value: "all"  # Options: all, sharegpt, short-input, long-input
        - name: QPS_VALUES
          value: "1.34 2.0 3.0"  # Space-separated list of QPS values
        volumeMounts:
        - name: results-volume
          mountPath: /app/results
      volumes:
      - name: results-volume
        persistentVolumeClaim:
          claimName: benchmark-results-pvc  # Replace with your actual PVC
      restartPolicy: Never
  backoffLimit: 0  # Don't retry on failure 
