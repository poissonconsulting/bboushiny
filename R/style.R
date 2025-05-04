# Copyright 2022-2023 Environment and Climate Change Canada
# Copyright 2024 Province of Alberta
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

css_styling <- function() {
  x <-
    "
  .fa-survival:before {
    font-weight: 700;
    content: 'S';
    margin-left: 0.5em;
  }
  .fa-recruitment:before {
    font-weight: 700;
    content: 'R';
    margin-left: 0.5em;
  }
  .fa-lambda:before {
    content: ' \\03BB';
    font-weight: 1000;
    margin-left: 0.5em;
  }
  .fa.fa-question-circle.shinyhelper-icon {
    color: #c3986d
  }
  .nav-tabs .nav-link.active {
    background-color: #c3986d;
    color: #fff;
  }

  .sidebar-light-primary .nav-sidebar .nav-item .nav-link.active {
    background-color: #c3986d;
    color: #fff;
  }
  a:hover {
    color: #c3986d;
  }
  a.nav-link {
    color: #343a40;
  }
  .content-wrapper {
    background-color: #f8f2ed;
  }
  .shiny-input-container {
	  margin-bottom: 0.5rem;
  }
  .btn.hover, .btn:hover {
    background-color: #c3986d;
    border-color: #c3986d;
  }
  .btn-primary.hover, .btn-primary:hover {
    background-color: #c3986d;
    border-color: #c3986d;
  }
  .btn.focus, .btn:focus {
    background-color: #c3986d;
    border-color: #c3986d;
  }
  .btn-primary.focus, .btn-primary:focus {
    background-color: #c3986d;
    border-color: #c3986d;
  }
  .btn.active, .btn:active {
    background-color: #c3986d6 !important;
    border-color: #c3986d !important;
  }
  .btn-primary.active, .btn-primary:active {
    background-color: #c3986d !important;
    border-color: #c3986d !important;
  }
  .progress-bar {
	  background-color: #c3986d;
  }
    .dataTables_wrapper.no-footer {
    margin-top: 20px;
  }
  .shiny-plot-output.shiny-bound-output {
    margin-top: 20px;
  }
  #mod_survival_ui-results_plot.shiny-plot-output.shiny-bound-output {
    margin-top: 5px;
  }
  .btn-results {
    float: right
  }
  .btn-results-table {
    float: right;
    margin-top: 5px;
    margin-bottom: 5px
  }

  .layout-navbar-fixed .wrapper .main-sidebar:hover .brand-link {
    transition:width .3s ease-in-out;
    width:220px
  }
  .layout-navbar-fixed .wrapper .brand-link {
    overflow:hidden;
    position:fixed;
    top:0;
    transition:width .3s ease-in-out;
    width:220px;
    z-index:1035
  }
  .layout-navbar-fixed .wrapper .main-sidebar:hover .brand-link {
    transition:width .3s ease-in-out;
    width:220px
  }
  .layout-navbar-fixed .wrapper .brand-link {
    overflow:hidden;
    position:fixed;
    top:0;
    transition:width .3s ease-in-out;
    width:220px;
    z-index:1035
  }
  .layout-sm-navbar-fixed .wrapper.sidebar-collapse .main-sidebar:hover .brand-link {
    transition:width .3s ease-in-out;
    width:220px
  }
  .layout-sm-navbar-fixed .wrapper .brand-link {
    overflow:hidden;
    position:fixed;
    top:0;
    transition:width .3s ease-in-out;
    width:220px;
    z-index:1035
  }
  .layout-md-navbar-fixed .wrapper.sidebar-collapse .main-sidebar:hover .brand-link {
    transition:width .3s ease-in-out;
    width:220px
  }
  .layout-md-navbar-fixed .wrapper .brand-link {
    overflow:hidden;position:fixed;
    top:0;
    transition:width .3s ease-in-out;
    width:220px;
    z-index:1035
  }
  .layout-lg-navbar-fixed .wrapper.sidebar-collapse .main-sidebar:hover .brand-link {
    transition:width .3s ease-in-out;
    width:220px
  }
  .layout-lg-navbar-fixed .wrapper .brand-link {
    overflow:hidden;
    position:fixed;
    top:0;
    transition:width .3s ease-in-out;
    width:220px;
    z-index:1035
  }
  .layout-xl-navbar-fixed .wrapper.sidebar-collapse .main-sidebar:hover .brand-link {
    transition:width .3s ease-in-out;
    width:220px
  }
  .layout-xl-navbar-fixed .wrapper .brand-link {
    overflow:hidden;
    position:fixed;
    top:0;
    transition:width .3s ease-in-out;
    width:220px;
    z-index:1035
  }
  @media (min-width: 768px) {
    body:not(.sidebar-mini-md) .content-wrapper,
    body:not(.sidebar-mini-md) .main-footer,
    body:not(.sidebar-mini-md) .main-header {
      transition:margin-left .3s ease-in-out;
      margin-left:220px
    }
  }
  @media (min-width: 768px) {
    .sidebar-mini-md .content-wrapper,
    .sidebar-mini-md .main-footer,
    .sidebar-mini-md .main-header {
      transition:margin-left .3s ease-in-out;
      margin-left:220px
    }
  }
  .main-sidebar,.main-sidebar::before {
    transition:margin-left .3s ease-in-out,
    width .3s ease-in-out;
    width:220px
  }
  .sidebar-collapse .main-sidebar,.sidebar-collapse .main-sidebar::before {
    margin-left:-220px
  }
  @media (max-width: 767.98px) {
    .main-sidebar,
    .main-sidebar::before {
      box-shadow:none !important;
      margin-left:-220px
    }
    .sidebar-open .main-sidebar,
    .sidebar-open .main-sidebar::before{
      margin-left:0
    }
  }
  .layout-fixed .brand-link {
    width:220px
  }
  .sidebar-mini.sidebar-collapse .main-sidebar:hover,.sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused {
    width:220px
  }
  .sidebar-mini.sidebar-collapse .main-sidebar:hover .brand-link,.sidebar-mini.sidebar-collapse .main-sidebar.sidebar-focused .brand-link {
    width:220px
  }
  .sidebar-mini.sidebar-collapse.layout-fixed .main-sidebar:hover .brand-link {
    width:220px
  }
  .sidebar-mini-md.sidebar-collapse .main-sidebar:hover,.sidebar-mini-md.sidebar-collapse .main-sidebar.sidebar-focused {
    width:220px
  }
  .sidebar-mini-md.sidebar-collapse .main-sidebar:hover .brand-link,.sidebar-mini-md.sidebar-collapse .main-sidebar.sidebar-focused .brand-link {
    width:220px
  }
  @media (min-width: 768px) {
    .sidebar-mini-md .content-wrapper,
    .sidebar-mini-md .main-footer,
    .sidebar-mini-md .main-header {
      transition:margin-left .3s ease-in-out;
      margin-left:220px
    }
  }
  .control-sidebar,.control-sidebar::before {
    bottom:calc(3.5rem + 1px);
    display:none;
    right:-220px;
    width:220px;
    transition:right .3s ease-in-out,display .3s ease-in-out
  }
  .control-sidebar-open.control-sidebar-push .content-wrapper,.control-sidebar-open.control-sidebar-push .main-footer,.control-sidebar-open.control-sidebar-push-slide .content-wrapper,.control-sidebar-open.control-sidebar-push-slide .main-footer {
    margin-right:220px
  }
  .control-sidebar-slide-open.control-sidebar-push .content-wrapper,.control-sidebar-slide-open.control-sidebar-push .main-footer,.control-sidebar-slide-open.control-sidebar-push-slide .content-wrapper,.control-sidebar-slide-open.control-sidebar-push-slide .main-footer {
    margin-right:220px
  }
  "
  tags$style(x, type = "text/css")
}
