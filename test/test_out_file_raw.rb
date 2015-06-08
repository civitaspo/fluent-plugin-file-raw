require_relative 'helper'
require 'rr'
require 'fileutils'
require 'fluent/plugin/out_file_raw'

Fluent::Test.setup

class FileRawOutputTest < Test::Unit::TestCase
  def setup
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
  end

  def create_driver(conf, use_v1 = true)
    Fluent::Test::OutputTestDriver.new(Fluent::FileRawOutput, @tag).configure(conf, use_v1)
  end

  TMP_DIR         = File.expand_path(File.dirname(__FILE__) + "/../tmp")
  TMP_FILE_PREFIX = "tmpfile"
  CONFIG          =
    %[
      output_path #{TMP_DIR}
      output_file_prefix #{TMP_FILE_PREFIX}
    ]

  def test_configure_output_path_prefix
    assert_raise(Fluent::ConfigError) do
      d = create_driver(%[output_path /hogehoge])
    end

    d = create_driver(CONFIG)
    assert_equal "#{TMP_DIR}/#{TMP_FILE_PREFIX}", d.instance.instance_variable_get(:@output_path_prefix)
  end

  def test_configure_delimiter
    assert_raise(Fluent::ConfigError) do
      d = create_driver(%[output_delimiter hogehoge])
    end

    d = create_driver(%[output_delimiter COMMA])
    assert_equal ",", d.instance.instance_variable_get(:@delimiter)

    d = create_driver(%[])
    assert_equal "", d.instance.instance_variable_get(:@delimiter)

    d = create_driver(%[output_delimiter TAB])
    assert_equal "\t", d.instance.instance_variable_get(:@delimiter)
  end

  def test_write_as_tsv
    d = create_driver(CONFIG + %[output_delimiter TAB\n])

    d.run do
      d.emit(["data1", "data2"])
      d.emit([Time.parse("2012-03-03 00:00:00 UTC").to_i, 0, 'action', '{"x": 1}'])
    end

    str = ''
    Dir.glob("#{d.instance.instance_variable_get(:@output_path_prefix)}**").each do |file_name|
      str << File.read(file_name)
    end

    assert_match %r{^#{["data1", "data2"].join("\t")}$}, str
    assert_match %r{^#{[Time.parse("2012-03-03 00:00:00 UTC").to_i, 0, 'action', '{"x": 1}'].join("\t")}$}, str
  end

  def test_write_as_csv
    d = create_driver(CONFIG + %[output_delimiter COMMA\n])

    d.run do
      d.emit(["data1", "data2"])
      d.emit([Time.parse("2012-03-03 00:00:00 UTC").to_i, 0, 'action', '{"x": 1}'])
    end

    str = ''
    Dir.glob("#{d.instance.instance_variable_get(:@output_path_prefix)}**").each do |file_name|
      str << File.read(file_name)
    end

    assert_match %r{^#{["data1", "data2"].join(",")}$}, str
    assert_match %r{^#{[Time.parse("2012-03-03 00:00:00 UTC").to_i, 0, 'action', '{"x": 1}'].join(",")}$}, str
  end

  def test_write_bulk
    d = create_driver(CONFIG + %[bulk_tag_prefix bulkdata\n])

    data1 = ''
    100.times do |i|
      data1 << "data#{i}\tdata#{i + 1}\tdata2#{i}\n"
    end

    data2 = ''
    100.times do |i|
      data2 << "#{i}\t0\taction#{i}\t{\"x\": 1}\n"
    end

    d.run do
      d.emit([data1, data2])
    end

    str = ''
    Dir.glob("#{d.instance.instance_variable_get(:@output_path_prefix)}**").each do |file_name|
      str << File.read(file_name)
    end

    data1.split("\n").each do |data|
      assert_match %r{^#{data}$}, str
    end

    data2.split("\n").each do |data|
      assert_match %r{^#{data}$}, str
    end
  end
end
