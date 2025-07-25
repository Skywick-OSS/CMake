set(timingDir "${RunCMake_TEST_BINARY_DIR}/.cmake/instrumentation-d16a3082-c4e1-489b-b90c-55750a334f27/v1")
file(READ "${timingDir}/query/generated/query-0.json" jsonData)
string(JSON options GET "${jsonData}" options)
if (options MATCHES cdashVerbose AND NOT ${RunCMake_USE_VERBOSE_INSTRUMENTATION})
  set(RunCMake_TEST_FAILED "cdashVerbose option not found in generated query despite environment variable")
elseif (NOT options MATCHES cdashVerbose AND ${RunCMake_USE_VERBOSE_INSTRUMENTATION})
  set(RunCMake_TEST_FAILED "cdashVerbose option found in generated query despite environment variable")
endif()

foreach(xml_type Configure Build Test)
  file(GLOB xml_file "${RunCMake_TEST_BINARY_DIR}/Testing/*/${xml_type}.xml")
  if(xml_file)
    file(READ "${xml_file}" xml_content)
    if(NOT xml_content MATCHES "AfterHostMemoryUsed")
      set(RunCMake_TEST_FAILED "'AfterHostMemoryUsed' not found in ${xml_type}.xml")
    endif()
    if(NOT xml_type STREQUAL "Test")
      if(NOT xml_content MATCHES "<Commands>")
        set(RunCMake_TEST_FAILED "<Commands> element not found in ${xml_type}.xml")
      endif()
    endif()
    if (xml_type STREQUAL "Build")
      if(NOT xml_content MATCHES "<Targets>")
        set(RunCMake_TEST_FAILED "<Targets> element not found in Build.xml")
      endif()
      if(NOT xml_content MATCHES "<Target name=\"main\" type=\"EXECUTABLE\">")
        set(RunCMake_TEST_FAILED "<Target> element for 'main' not found in Build.xml")
      endif()
      if(NOT xml_content MATCHES "<Compile")
        set(RunCMake_TEST_FAILED "<Compile> element not found in Build.xml")
      endif()
      if(NOT xml_content MATCHES "<Outputs")
        set(RunCMake_TEST_FAILED "<Outputs> element not found in Build.xml")
      endif()
      if(NOT xml_content MATCHES "<Link")
        set(RunCMake_TEST_FAILED "<Link> element not found in Build.xml")
      endif()
      if(NOT xml_content MATCHES "<CmakeBuild")
        set(RunCMake_TEST_FAILED "<CmakeBuild> element not found in Build.xml")
      endif()
      if(NOT RunCMake_USE_VERBOSE_INSTRUMENTATION AND NOT xml_content MATCHES "(truncated)")
        set(RunCMake_TEST_FAILED "Commands not truncated despite cdashVerbose option")
      endif()
      if(verbose AND xml_content MATCHES "(truncated)")
        set(RunCMake_TEST_FAILED "Commands truncated despite cdashVerbose option")
      endif()
    endif()
  else()
    set(RunCMake_TEST_FAILED "${xml_type}.xml not found")
  endif()
endforeach()

foreach(dir_to_check "configure" "test" "build/targets" "build/commands")
  file(GLOB leftover_cdash_snippets
    "${timingDir}/cdash/${dir_to_check}/*")
  if(leftover_cdash_snippets)
    set(RunCMake_TEST_FAILED "Leftover snippets found in cdash dir: ${leftover_cdash_snippets}")
  endif()
endforeach()
