#
# Cookbook Name:: cacti
# Provider:: graph
#
# Author:: Elan Ruusamäe <glen@delfi.ee>
#
# Copyright 2014, Elan Ruusamäe
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include Cacti::Cli

def whyrun_supported?
  true
end

def load_current_resource
  # handle name attribute
  unless new_resource.graph_template
    new_resource.graph_template new_resource.name
  end
end

def graph_exists?
  begin
    host_id = get_host_id(new_resource.host)
    get_graph_id(host_id, new_resource.graph_template, 2)
    return true
  rescue => e
    return false
  end
end

def params
  params = ''
  params << %Q[ --graph-template-id="#{get_graph_template_id(new_resource.graph_template)}"]
  params << %Q[ --host-id="#{get_host_id(new_resource.host)}"]
  params << %Q[ --graph-type="#{new_resource.graph_type}"]

  case new_resource.graph_type
  when 'cg'
    params << %Q[ --input-fields="#{flatten_fields(new_resource.input_fields)}"]
  when 'ds'
    snmp_query_id = get_snmp_query(new_resource.snmp_query)
    snmp_query_type_id = get_snmp_query_type(snmp_query_id, new_resource.snmp_query_type)
    params << %Q[ --snmp-query-id="#{snmp_query_id}"]
    params << %Q[ --snmp-query-type-id="#{snmp_query_type_id}"]
    params << %Q[ --snmp-field="#{new_resource.snmp_field}"]
    params << %Q[ --snmp-value="#{new_resource.snmp_value}"]

  end
  # TODO: rest of the params

  params
end

action :create do
  if graph_exists?
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("create #{new_resource}") do
      r = add_graphs(params)
      new_resource.updated_by_last_action true if r
    end
  end
end
