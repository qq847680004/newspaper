#!/usr/bin/env bash
# 生成本周工作记录模板 work-record.md（周一到周五，日期之间空 6 行）
# 依赖 GNU date 的 -d 选项（Git Bash 自带）；目标文件已存在时跳过
# 日期归属与 weekly-report 读取日报的规则严格一致：周一到周五按日期归月，
# 跨月周（如 8/31~9/4）里跨入下月的日期（9/1~9/4）放到下月第一个周目录，
# 不在周一所在月的目录里列出下月日期

# 指定 UTF-8 locale，避免 MSYS 把中文目录名按本地代码页转换导致乱码
export LANG=C.UTF-8

set -e

# 本周周一：当前日期 - (星期几 - 1) 天，%u 中 1=周一
TODAY=$(date +%Y-%m-%d)
DOW=$(date +%u)
MONDAY=$(date -d "$TODAY - $((DOW - 1)) days" +%Y-%m-%d)

# 第 N 周 = 该月第 N 个周一，与 weekly-report skill 口径一致（周数用汉字：第四周）
DAY_OF_MONTH=$(date -d "$MONDAY" +%d)
WEEK_NO=$(((10#$DAY_OF_MONTH - 1) / 7 + 1))
CHINESE_NUM=(一 二 三 四 五)
WEEK_CN=${CHINESE_NUM[$((WEEK_NO - 1))]}

CUR_MONTH=$(date -d "$MONDAY" +%Y-%m)

# 生成一个模板文件：写入传入的日期列表
write_record() {
  local dir="$1"; shift
  local file="$dir/work-record.md"

  if [ -f "$file" ]; then
    echo "已存在，跳过：$file"
    return
  fi

  mkdir -p "$dir"

  {
    for d in "$@"; do
      echo "============$d============"
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
      echo ""
    done
  } > "$file"

  echo "已生成：$file"
}

# 拆分周一到周五：与周一同月的日期留该月第 N 周目录，跨入下月的日期归下月
MONTH_DATES=()
NEXT_MONTH_DATES=()
for i in 0 1 2 3 4; do
  D=$(date -d "$MONDAY + $i days" +%Y-%m-%d)
  DM=$(date -d "$MONDAY + $i days" +%Y-%m)
  if [ "$DM" = "$CUR_MONTH" ]; then
    MONTH_DATES+=("$D")
  else
    NEXT_MONTH_DATES+=("$D")
  fi
done

# 周一所在月的日期：该月第 N 周目录（如 2026-08-第五周）
if [ ${#MONTH_DATES[@]} -gt 0 ]; then
  write_record "newspaper/daily/${CUR_MONTH}-第${WEEK_CN}周" "${MONTH_DATES[@]}"
fi

# 跨入下月的日期：下月第一个周目录（如 2026-09-第一周，与下月第一周日报同目录，靠日期过滤区分）
if [ ${#NEXT_MONTH_DATES[@]} -gt 0 ]; then
  NEXT_MONTH=$(date -d "${NEXT_MONTH_DATES[0]}" +%Y-%m)
  write_record "newspaper/daily/${NEXT_MONTH}-第一周" "${NEXT_MONTH_DATES[@]}"
fi
